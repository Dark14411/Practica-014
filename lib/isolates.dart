import 'package:built_collection/built_collection.dart';
import 'package:characters/characters.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

import 'model.dart';
import 'utils.dart';

Stream<WorkQueue> exploreCrosswordSolutions({
  required Crossword crossword,
  required BuiltSet<String> wordList,
  required int maxWorkerCount,
}) async* {
  final start = DateTime.now();

  // Optimizar el número de workers basado en el tamaño del grid - MÁS AGRESIVO
  final optimizedWorkerCount = _optimizeWorkerCount(crossword, maxWorkerCount);

  var workQueue = WorkQueue.from(
    crossword: crossword,
    candidateWords: wordList,
    startLocation: Location.at(0, 0),
  );

  // Límite de iteraciones más agresivo basado en el tamaño del grid
  final maxIterations = _getMaxIterations(crossword);
  int iterationCount = 0;

  // Timeout más agresivo basado en el tamaño del grid
  final maxDuration = _getMaxDuration(crossword);

  while (!workQueue.isCompleted && iterationCount < maxIterations) {
    // Verificar cancelación al inicio de cada iteración
    // Nota: La cancelación se maneja desde el lado del UI, no podemos acceder a providers aquí

    try {
      workQueue = await compute(_generate, (workQueue, optimizedWorkerCount));
      yield workQueue;
      iterationCount++;

      // Verificar timeout más frecuentemente
      final elapsed = DateTime.now().difference(start);
      if (elapsed > maxDuration) {
        debugPrint(
          'Timeout: Generation taking too long (${elapsed.inSeconds}s), stopping at iteration $iterationCount',
        );
        break;
      }

      // Para grids muy grandes, verificar progreso cada pocas iteraciones
      if (crossword.width * crossword.height > 60 * 33 &&
          iterationCount % 5 == 0) {
        final progress =
            workQueue.crossword.characters.length /
            (crossword.width * crossword.height);
        if (progress < 0.1 && iterationCount > 10) {
          debugPrint('Low progress detected, stopping early to prevent freeze');
          break;
        }
      }
    } catch (e) {
      debugPrint('Error running isolate: $e');
      break;
    }
  }

  debugPrint(
    'Generated ${workQueue.crossword.width} x '
    '${workQueue.crossword.height} crossword in '
    '${DateTime.now().difference(start).formatted} '
    'with $optimizedWorkerCount workers (${iterationCount} iterations).',
  );
}

/// Optimiza el número de workers basado en el tamaño del grid para evitar sobrecarga
int _optimizeWorkerCount(Crossword crossword, int requestedWorkers) {
  final gridSize = crossword.width * crossword.height;

  // Para grids pequeños, workers moderados
  if (gridSize <= 20 * 11) {
    return min(requestedWorkers, 8);
  }
  // Para grids medianos, reducir workers
  else if (gridSize <= 40 * 22) {
    return min(requestedWorkers, 4);
  }
  // Para grids grandes, muy pocos workers
  else if (gridSize <= 60 * 33) {
    return min(requestedWorkers, 2);
  }
  // Para grids muy grandes, solo 1 worker
  else {
    return 1;
  }
}

/// Obtiene el límite máximo de iteraciones basado en el tamaño del grid
int _getMaxIterations(Crossword crossword) {
  final gridSize = crossword.width * crossword.height;

  if (gridSize <= 20 * 11) return 200; // Pequeño: más iteraciones
  if (gridSize <= 40 * 22) return 100; // Mediano: iteraciones moderadas
  if (gridSize <= 60 * 33) return 50; // Grande: menos iteraciones
  return 25; // Muy grande: muy pocas iteraciones
}

/// Obtiene la duración máxima permitida basada en el tamaño del grid
Duration _getMaxDuration(Crossword crossword) {
  final gridSize = crossword.width * crossword.height;

  if (gridSize <= 20 * 11) return const Duration(seconds: 10);
  if (gridSize <= 40 * 22) return const Duration(seconds: 15);
  if (gridSize <= 60 * 33) return const Duration(seconds: 20);
  return const Duration(seconds: 25);
}

Future<WorkQueue> _generate((WorkQueue, int) workMessage) async {
  var (workQueue, maxWorkerCount) = workMessage;
  final candidateGeneratorFutures = <Future<(Location, Direction, String?)>>[];
  final locations = workQueue.locationsToTry.keys.toBuiltList().rebuild(
    (b) => b
      ..shuffle()
      ..take(maxWorkerCount),
  );

  for (final location in locations) {
    final direction = workQueue.locationsToTry[location]!;

    candidateGeneratorFutures.add(
      compute(_generateCandidate, (
        workQueue.crossword,
        workQueue.candidateWords,
        location,
        direction,
      )),
    );
  }

  try {
    final results = await candidateGeneratorFutures.wait;
    var crossword = workQueue.crossword;
    for (final (location, direction, word) in results) {
      if (word != null) {
        final candidate = crossword.addWord(
          location: location,
          word: word,
          direction: direction,
        );
        if (candidate != null) {
          crossword = candidate;
        }
      } else {
        workQueue = workQueue.remove(location);
      }
    }

    workQueue = workQueue.updateFrom(crossword);
  } catch (e) {
    debugPrint('$e');
  }

  return workQueue;
}

(Location, Direction, String?) _generateCandidate(
  (Crossword, BuiltSet<String>, Location, Direction) searchDetailMessage,
) {
  final (crossword, candidateWords, location, direction) = searchDetailMessage;

  final target = crossword.characters[location];
  if (target == null) {
    return (location, direction, candidateWords.randomElement());
  }

  // Filter down the candidate word list to those that contain the letter
  // at the current location
  final words = candidateWords.toBuiltList().rebuild(
    (b) => b
      ..where((b) => b.characters.contains(target.character))
      ..shuffle(),
  );

  if (words.isEmpty) {
    return (location, direction, null);
  }

  // Optimizar límites basados en el tamaño del grid - MÁS AGRESIVOS
  final gridSize = crossword.width * crossword.height;
  final (maxTries, timeout) = gridSize <= 20 * 11
      ? (100, const Duration(seconds: 2)) // Pequeño: más intentos
      : gridSize <= 40 * 22
      ? (50, const Duration(seconds: 3)) // Mediano: intentos moderados
      : gridSize <= 60 * 33
      ? (25, const Duration(seconds: 4)) // Grande: menos intentos
      : (10, const Duration(seconds: 5)); // Muy grande: muy pocos intentos

  int tryCount = 0;
  final start = DateTime.now();

  // Limitar el número de palabras a probar - MÁS AGRESIVO PARA GRIDS GRANDES
  final wordsToTry = words.take(min(words.length, maxTries));

  for (final word in wordsToTry) {
    tryCount++;

    // Verificar timeout más frecuentemente para grids grandes
    if (gridSize > 40 * 22 && tryCount % 5 == 0) {
      final deltaTime = DateTime.now().difference(start);
      if (deltaTime > timeout) {
        return (location, direction, null);
      }
    }

    // Para grids muy grandes, verificar cada intento
    if (gridSize > 60 * 33) {
      final deltaTime = DateTime.now().difference(start);
      if (deltaTime > timeout) {
        return (location, direction, null);
      }
    }

    for (final (index, character) in word.characters.indexed) {
      if (character != target.character) continue;

      final candidate = crossword.addWord(
        location: switch (direction) {
          Direction.across => location.leftOffset(index),
          Direction.down => location.upOffset(index),
        },
        word: word,
        direction: direction,
      );
      if (candidate != null) {
        return switch (direction) {
          Direction.across => (location.leftOffset(index), direction, word),
          Direction.down => (location.upOffset(index), direction, word),
        };
      }
    }
  }

  return (location, direction, null);
}
