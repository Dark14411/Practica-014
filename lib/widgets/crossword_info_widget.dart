import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../providers.dart';
import '../services/player_service.dart';
import 'ticker_builder.dart';

// Provider para actualizar el score cada segundo
final _scoreUpdaterProvider = StreamProvider.autoDispose((ref) async* {
  final gameSession = ref.watch(gameSessionProvider);
  if (gameSession != null && gameSession.isPlaying) {
    yield* Stream.periodic(const Duration(seconds: 1), (count) {
      ref.read(gameSessionProvider.notifier).updateScore();
      return count;
    });
  }
});

class CrosswordInfoWidget extends ConsumerWidget {
  const CrosswordInfoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Activar actualización automática del score
    ref.watch(_scoreUpdaterProvider);

    final size = ref.watch(sizeProvider);
    final displayInfo = ref.watch(displayInfoProvider);
    final workerCount = ref.watch(workerCountProvider).label;
    final gameSession = ref.watch(gameSessionProvider);

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.45,
              maxHeight: MediaQuery.sizeOf(context).height * 0.6,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (gameSession != null && gameSession.isPlaying) ...[
                      _GameTimeWidget(score: gameSession.currentScore),
                      _CrosswordInfoRow(
                        label: 'Palabras encontradas',
                        value: gameSession.wordsFound.toString(),
                        highlight: true,
                      ),
                      const Divider(height: 16),
                    ],
                    _CrosswordInfoRow(
                      label: 'Grid Size',
                      value: '${size.width} x ${size.height}',
                    ),
                    _CrosswordInfoRow(
                      label: 'Words in crossword',
                      value: displayInfo.wordsInGridCount,
                    ),
                    _CrosswordInfoRow(
                      label: 'Candidate words',
                      value: displayInfo.candidateWordsCount,
                    ),
                    _CrosswordInfoRow(
                      label: 'Locations to explore',
                      value: displayInfo.locationsToExploreCount,
                    ),
                    _CrosswordInfoRow(
                      label: 'Known bad locations',
                      value: displayInfo.knownBadLocationsCount,
                    ),
                    _CrosswordInfoRow(
                      label: 'Grid filled',
                      value: displayInfo.gridFilledPercentage,
                    ),
                    _CrosswordInfoRow(
                      label: 'Max worker count',
                      value: workerCount,
                    ),
                    const _ElapsedTimeWidget(),
                    const _RemainingTimeWidget(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget optimizado para mostrar el tiempo del juego
class _GameTimeWidget extends ConsumerWidget {
  final int score;

  const _GameTimeWidget({required this.score});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TickerBuilder(
      builder: (context) {
        final currentScore =
            ref.watch(gameSessionProvider)?.currentScore ?? score;
        final minutes = currentScore ~/ 60;
        final seconds = currentScore % 60;
        return _CrosswordInfoRow(
          label: 'Tiempo',
          value: '${minutes}m ${seconds}s',
          highlight: true,
        );
      },
    );
  }
}

// Widget optimizado para mostrar el tiempo transcurrido
class _ElapsedTimeWidget extends ConsumerWidget {
  const _ElapsedTimeWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startTime = ref.watch(startTimeProvider);
    final endTime = ref.watch(endTimeProvider);

    return TickerBuilder(
      builder: (context) {
        final elapsedTime = endTime == null
            ? DateTime.now().difference(startTime)
            : endTime.difference(startTime);
        final elapsedSeconds = elapsedTime.inSeconds;
        final hours = elapsedSeconds ~/ 3600;
        final minutes = (elapsedSeconds % 3600) ~/ 60;
        final seconds = elapsedSeconds % 60;

        return _CrosswordInfoRow(
          label: 'Elapsed time',
          value:
              '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
        );
      },
    );
  }
}

// Widget optimizado para mostrar el tiempo restante estimado
class _RemainingTimeWidget extends ConsumerWidget {
  const _RemainingTimeWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final endTime = ref.watch(endTimeProvider);

    if (endTime != null) return const SizedBox.shrink();

    return TickerBuilder(
      builder: (context) {
        final expectedRemaining = ref.read(expectedRemainingTimeProvider);
        final remainingSeconds = expectedRemaining.inSeconds;
        final hours = remainingSeconds ~/ 3600;
        final minutes = (remainingSeconds % 3600) ~/ 60;
        final seconds = remainingSeconds % 60;

        return _CrosswordInfoRow(
          label: 'Est. remaining time',
          value:
              '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
        );
      },
    );
  }
}

class _CrosswordInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _CrosswordInfoRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 3,
            child: Text(
              '$label: ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: highlight ? Colors.green.shade700 : null,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: highlight ? FontWeight.bold : null,
                color: highlight ? Colors.green.shade700 : null,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
