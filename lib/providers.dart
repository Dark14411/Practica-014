import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'isolates.dart';
import 'model.dart' as model;
import 'services/supabase_service.dart';

part 'providers.g.dart';

/// A provider for the wordlist to use when generating the crossword.
@riverpod
Future<BuiltSet<String>> wordList(Ref ref) async {
  // Obtiene palabras según modo: ONLINE = Supabase, OFFLINE = aleatorias
  final words = await SupabaseService.fetchWords();

  debugPrint('📝 Total words available: ${words.length}');

  return words;
}

/// An enumeration for different sizes of [model.Crossword]s.
enum CrosswordSize {
  small(width: 20, height: 11),
  medium(width: 40, height: 22),
  large(width: 80, height: 44),
  xlarge(width: 160, height: 88),
  xxlarge(width: 500, height: 500);

  const CrosswordSize({required this.width, required this.height});

  final int width;
  final int height;
  String get label => '$width x $height';
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
}
