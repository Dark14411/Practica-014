import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import '../interactive_providers.dart';
import '../model.dart';
import '../providers.dart';

class CrosswordWidget extends ConsumerWidget {
  const CrosswordWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = ref.watch(sizeProvider);
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(80),
      minScale: 0.5,
      maxScale: 4.0,
      child: SizedBox(
        width: size.width * 32.0,
        height: size.height * 32.0,
        child: TableView.builder(
          diagonalDragBehavior: DiagonalDragBehavior.free,
          cellBuilder: _buildCell,
          columnCount: size.width,
          columnBuilder: (index) => _buildSpan(context, index),
          rowCount: size.height,
          rowBuilder: (index) => _buildSpan(context, index),
        ),
      ),
    );
  }

  TableViewCell _buildCell(BuildContext context, TableVicinity vicinity) {
    final location = Location.at(vicinity.column, vicinity.row);

    return TableViewCell(
      child: Consumer(
        builder: (context, ref, _) {
          final character = ref.watch(
            workQueueProvider.select(
              (workQueueAsync) => workQueueAsync.when(
                data: (workQueue) => workQueue.crossword.characters[location],
                error: (error, stackTrace) => null,
                loading: () => null,
              ),
            ),
          );

          final explorationCell = ref.watch(
            workQueueProvider.select(
              (workQueueAsync) => workQueueAsync.when(
                data: (workQueue) =>
                    workQueue.locationsToTry.keys.contains(location),
                error: (error, stackTrace) => false,
                loading: () => false,
              ),
            ),
          );

          if (character != null) {
            // Obtener modo interactivo y palabras descubiertas
            final interactiveMode = ref.watch(interactiveModeProvider);
            final discoveredWords = ref.watch(discoveredWordsProvider);

            // Verificar si esta letra pertenece a una palabra descubierta
            final wordAtLocation = ref.watch(
              workQueueProvider.select(
                (workQueueAsync) => workQueueAsync.when(
                  data: (workQueue) {
                    // Buscar si hay alguna palabra que contenga esta ubicación
                    for (final word in workQueue.crossword.words) {
                      for (int i = 0; i < word.word.length; i++) {
                        final wordLoc = word.direction == Direction.across
                            ? word.location.rightOffset(i)
                            : word.location.downOffset(i);
                        if (wordLoc == location) {
                          return word.word;
                        }
                      }
                    }
                    return null;
                  },
                  error: (_, __) => null,
                  loading: () => null,
                ),
              ),
            );

            final isWordDiscovered =
                wordAtLocation != null &&
                discoveredWords.contains(wordAtLocation.toLowerCase());
            final shouldShow = !interactiveMode || isWordDiscovered;

            return GestureDetector(
              onTap: () {
                // Descubrir palabra al hacer clic
                if (interactiveMode &&
                    wordAtLocation != null &&
                    !isWordDiscovered) {
                  ref
                      .read(discoveredWordsProvider.notifier)
                      .discoverWord(wordAtLocation);
                }
              },
              child: AnimatedContainer(
                duration: Durations.extralong1,
                curve: Curves.easeInOut,
                color: explorationCell
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onPrimary,
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: Durations.extralong1,
                    curve: Curves.easeInOut,
                    style: TextStyle(
                      fontSize: 24,
                      color: explorationCell
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(shouldShow ? character.character : ''),
                  ),
                ),
              ),
            );
          }

          return ColoredBox(
            color: Theme.of(context).colorScheme.primaryContainer,
          );
        },
      ),
    );
  }

  TableSpan _buildSpan(BuildContext context, int index) {
    return TableSpan(
      extent: FixedTableSpanExtent(32),
      foregroundDecoration: TableSpanDecoration(
        border: TableSpanBorder(
          leading: BorderSide(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          trailing: BorderSide(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
