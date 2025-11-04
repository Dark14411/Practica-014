import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../services/user_service.dart';
import 'ticker_builder.dart';

class CrosswordInfoWidget extends ConsumerWidget {
  const CrosswordInfoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = ref.watch(sizeProvider);
    final displayInfo = ref.watch(displayInfoProvider);
    final workerCount = ref.watch(workerCountProvider).label;
    final startTime = ref.watch(startTimeProvider);
    final endTime = ref.watch(endTimeProvider);
    final gameSession = ref.watch(gameSessionProvider);

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ColoredBox(
            color: Theme.of(context).colorScheme.onPrimary.withAlpha(230),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mostrar score si hay sesión activa
                    if (gameSession != null && gameSession.isPlaying) ...[
                      TickerBuilder(
                        builder: (context) {
                          ref.read(gameSessionProvider.notifier).updateScore();
                          final score =
                              ref.watch(gameSessionProvider)?.currentScore ?? 0;
                          final minutes = score ~/ 60;
                          final seconds = score % 60;
                          return _CrosswordInfoRow(
                            label: 'Tiempo',
                            value: '${minutes}m ${seconds}s',
                            highlight: true,
                          );
                        },
                      ),
                      _CrosswordInfoRow(
                        label: 'Palabras encontradas',
                        value: gameSession.wordsFound.toString(),
                        highlight: true,
                      ),
                      const Divider(),
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
                    TickerBuilder(
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
                    ),
                    if (endTime == null)
                      TickerBuilder(
                        builder: (context) {
                          final expectedRemaining = ref.read(
                            expectedRemainingTimeProvider,
                          );
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
                      ),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: highlight ? Colors.green.shade700 : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: highlight ? FontWeight.bold : null,
              color: highlight ? Colors.green.shade700 : null,
            ),
          ),
        ],
      ),
    );
  }
}
