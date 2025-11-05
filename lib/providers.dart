import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'isolates.dart';
import 'model.dart' as model;
import 'services/supabase_service.dart';

part 'providers.g.dart';

/// A provider for the wordlist to use when generating the crossword.
@Riverpod(keepAlive: true)
Future<BuiltSet<String>> wordList(Ref ref) async {
  // Obtiene palabras según modo: ONLINE = Supabase, OFFLINE = aleatorias
  final words = await SupabaseService.fetchWords();

  debugPrint('📝 Total words available: ${words.length}');

  return words;
}

/// A provider that tracks which words come from the database
@Riverpod(keepAlive: true)
Future<BuiltSet<String>> databaseWords(Ref ref) async {
  final dbWords = await SupabaseService.fetchDatabaseWords();
  return dbWords;
}

/// An enumeration for different sizes of [model.Crossword]s.
enum CrosswordSize {
  small(width: 20, height: 11),
  medium(width: 40, height: 22),
  large(width: 60, height: 33),
  xlarge(width: 80, height: 44);

  const CrosswordSize({required this.width, required this.height});

  final int width;
  final int height;
  String get label => '$width x $height';

  /// Verifica si el tamaño es adecuado para el rendimiento
  bool get isPerformanceSafe => width * height <= 60 * 33;

  /// Tiempo máximo recomendado para este tamaño (en segundos)
  int get recommendedTimeout => switch (this) {
    CrosswordSize.small => 5,
    CrosswordSize.medium => 10,
    CrosswordSize.large => 20,
    CrosswordSize.xlarge => 30,
  };

  /// Número máximo de workers recomendado para este tamaño
  int get maxRecommendedWorkers => switch (this) {
    CrosswordSize.small => 8,
    CrosswordSize.medium => 4,
    CrosswordSize.large => 2,
    CrosswordSize.xlarge => 1,
  };
}

/// A provider that holds the current size of the crossword to generate.
@Riverpod(keepAlive: true)
class Size extends _$Size {
  var _size = CrosswordSize.medium;

  @override
  CrosswordSize build() => _size;

  void setSize(CrosswordSize size) {
    _size = size;
    ref.invalidateSelf();
  }
}

@riverpod
Stream<model.WorkQueue> workQueue(Ref ref) async* {
  final workers = ref.watch(workerCountProvider);
  final size = ref.watch(sizeProvider);
  final wordListAsync = ref.watch(wordListProvider);

  final emptyCrossword = model.Crossword.crossword(
    width: size.width,
    height: size.height,
  );

  yield* wordListAsync.when(
    data: (wordList) => exploreCrosswordSolutions(
      crossword: emptyCrossword,
      wordList: wordList,
      maxWorkerCount: workers.count,
    ),
    error: (error, stackTrace) async* {
      debugPrint('Error loading word list: $error');
      yield model.WorkQueue();
    },
    loading: () async* {
      yield model.WorkQueue();
    },
  );
}

/// Un proveedor de la hora de inicio del crucigrama.
@riverpod
DateTime startTime(Ref ref) {
  var workQueueAsync = ref.watch(workQueueProvider);
  if (workQueueAsync is AsyncData<model.WorkQueue> &&
      workQueueAsync.value.isCompleted) {
    ref.invalidateSelf(); // Resetear cuando se complete
  }
  return DateTime.now();
}

/// Un proveedor de la hora de finalización del crucigrama.
@riverpod
DateTime? endTime(Ref ref) {
  var workQueueAsync = ref.watch(workQueueProvider);
  if (workQueueAsync is AsyncData<model.WorkQueue>) {
    if (workQueueAsync.value.isCompleted) {
      return DateTime.now();
    }
  }
  return null;
}

/// Un proveedor del tiempo esperado restante para completar el crucigrama.
@riverpod
Duration expectedRemainingTime(Ref ref) {
  final startTime = ref.watch(startTimeProvider);
  final workQueueAsync = ref.watch(workQueueProvider);

  if (workQueueAsync is AsyncData<model.WorkQueue>) {
    final workQueue = workQueueAsync.value;
    if (workQueue.isCompleted) {
      return Duration.zero;
    }

    final percent =
        workQueue.crossword.characters.length /
        (workQueue.crossword.width * workQueue.crossword.height);
    final timeElapsed = DateTime.now().difference(startTime);
    final expectedTotal = timeElapsed.inSeconds / percent;
    final expectedRemaining = expectedTotal - timeElapsed.inSeconds;
    return Duration(seconds: max(0, expectedRemaining.toInt()));
  }
  return Duration.zero;
}

/// Un proveedor de si mostrar o no la información del crucigrama.
final showDisplayInfoProvider = StateProvider<bool>((ref) => false);

/// Un proveedor de la información a mostrar sobre el crucigrama.
@riverpod
model.DisplayInfo displayInfo(Ref ref) {
  final workQueueAsync = ref.watch(workQueueProvider);

  if (workQueueAsync is AsyncData<model.WorkQueue>) {
    final workQueue = workQueueAsync.value;
    return model.DisplayInfo.from(workQueue: workQueue);
  }

  return model.DisplayInfo.empty;
}

enum BackgroundWorkers {
  one(1),
  two(2),
  four(4),
  eight(8),
  sixteen(16),
  thirtyTwo(32),
  sixtyFour(64),
  oneTwentyEight(128);

  const BackgroundWorkers(this.count);

  final int count;
  String get label => count.toString();
}

/// A provider that holds the current number of background workers to use.
@Riverpod(keepAlive: true)
class WorkerCount extends _$WorkerCount {
  var _count = BackgroundWorkers.four;

  @override
  BackgroundWorkers build() => _count;

  void setCount(BackgroundWorkers count) {
    _count = count;
    ref.invalidateSelf();
  }

  /// Ajusta automáticamente el número de workers basado en el tamaño del grid
  void optimizeForSize(CrosswordSize size) {
    final recommended = size.maxRecommendedWorkers;
    final currentOptimal =
        BackgroundWorkers.values
            .where((w) => w.count <= recommended)
            .lastOrNull ??
        BackgroundWorkers.one;

    if (_count.count > recommended) {
      setCount(currentOptimal);
    }
  }
}

/// Provider que genera palabras objetivo aleatorias del crucigrama
@riverpod
BuiltSet<String> targetWords(Ref ref) {
  final workQueueAsync = ref.watch(workQueueProvider);

  if (workQueueAsync is AsyncData<model.WorkQueue>) {
    final crossword = workQueueAsync.value.crossword;
    final allWords = <String>[];

    // Recopilar todas las palabras del crucigrama
    for (final word in crossword.words) {
      allWords.add(word.word.toLowerCase());
    }

    if (allWords.isEmpty) {
      return BuiltSet<String>();
    }

    // Seleccionar entre 5 y 10 palabras aleatorias (o todas si hay menos)
    final random = Random();
    final targetCount = min(
      allWords.length,
      5 + random.nextInt(6),
    ); // 5-10 palabras
    allWords.shuffle(random);

    return BuiltSet<String>(allWords.take(targetCount));
  }

  return BuiltSet<String>();
}

/// Provider para controlar la cancelación de la generación del crucigrama
final generationCancellationProvider = StateProvider<bool>((ref) => false);

/// Provider para el temporizador del juego (cuenta regresiva)
final gameTimerProvider = StateNotifierProvider<GameTimerNotifier, int>((ref) {
  return GameTimerNotifier();
});

class GameTimerNotifier extends StateNotifier<int> {
  GameTimerNotifier() : super(0);

  /// Inicia el temporizador con un tiempo inicial (en segundos)
  void start({int initialSeconds = 120}) {
    state = initialSeconds; // 2 minutos por defecto
  }

  /// Agrega tiempo al temporizador (15 segundos por palabra encontrada)
  void addTime({int seconds = 15}) {
    if (state > 0) {
      state = state + seconds;
    }
  }

  /// Cuenta regresiva (llamar cada segundo)
  void tick() {
    if (state > 0) {
      state = state - 1;
    }
  }

  /// Detiene el temporizador
  void stop() {
    state = 0;
  }

  /// Resetea el temporizador
  void reset() {
    state = 0;
  }
}
