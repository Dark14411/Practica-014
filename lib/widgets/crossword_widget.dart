import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import '../interactive_providers.dart';
import '../model.dart';
import '../providers.dart' as app_providers;
import '../services/player_service.dart' as player_service;
import 'victory_dialog.dart';

class CrosswordWidget extends ConsumerWidget {
  const CrosswordWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = ref.watch(app_providers.sizeProvider);
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(80),
      minScale: 0.5,
      maxScale: 4.0,
      constrained: false,
      panEnabled: true,
      scaleEnabled: true,
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
            app_providers.workQueueProvider.select(
              (workQueueAsync) => workQueueAsync.when(
                data: (workQueue) => workQueue.crossword.characters[location],
                error: (error, stackTrace) => null,
                loading: () => null,
              ),
            ),
          );

          final explorationCell = ref.watch(
            app_providers.workQueueProvider.select(
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

            // Obtener palabras de base de datos
            final databaseWordsAsync = ref.watch(
              app_providers.databaseWordsProvider,
            );

            // Verificar si esta letra pertenece a una palabra descubierta
            final wordAtLocation = ref.watch(
              app_providers.workQueueProvider.select(
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

            // Verificar si la palabra es de base de datos
            final isDatabaseWord = databaseWordsAsync.maybeWhen(
              data: (dbWords) =>
                  wordAtLocation != null &&
                  dbWords.contains(wordAtLocation.toLowerCase()),
              orElse: () => false,
            );

            final shouldShow = !interactiveMode || isWordDiscovered;

            return InkWell(
              onTap: () {
                // Descubrir palabra al hacer clic si hay una palabra en esta ubicación
                if (interactiveMode &&
                    wordAtLocation != null &&
                    !isWordDiscovered) {
                  // Descubrir la palabra visualmente
                  ref
                      .read(discoveredWordsProvider.notifier)
                      .discoverWord(wordAtLocation);

                  // Registrar en la sesión de juego si hay una activa
                  final gameSession = ref.read(
                    player_service.gameSessionProvider,
                  );
                  if (gameSession != null && gameSession.isPlaying) {
                    // Verificar si esta palabra es una de las objetivo
                    if (gameSession.targetWords.contains(
                      wordAtLocation.toLowerCase(),
                    )) {
                      // Calcular puntos (10 puntos por palabra)
                      final points = 10;

                      // Actualizar la sesión con la palabra encontrada
                      ref
                          .read(player_service.gameSessionProvider.notifier)
                          .addFoundWord(wordAtLocation, points);

                      // Agregar 15 segundos al temporizador por palabra encontrada
                      ref
                          .read(app_providers.gameTimerProvider.notifier)
                          .addTime(seconds: 15);

                      // Verificar si ganó
                      final updatedSession = ref.read(
                        player_service.gameSessionProvider,
                      );
                      if (updatedSession != null &&
                          updatedSession.isCompleted) {
                        // Mostrar diálogo de victoria
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (context.mounted) {
                            showVictoryDialog(context, updatedSession);
                          }
                        });
                      }
                    }
                  }
                }
                // Los cuadros azules (explorationCell) también responden al tap
                // aunque no tengan una palabra específica
              },
              child: AnimatedContainer(
                duration: Durations.extralong1,
                curve: Curves.easeInOut,
                color: explorationCell
                    ? Theme.of(context).colorScheme.primary
                    : isWordDiscovered
                    ? Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.3)
                    : isDatabaseWord
                    ? Colors.blue.shade700.withValues(
                        alpha: 0.4,
                      ) // Fondo azul FUERTE para palabras de BD
                    : Theme.of(context).colorScheme.onPrimary,
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: Durations.extralong1,
                    curve: Curves.easeInOut,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: isWordDiscovered
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: explorationCell
                          ? Theme.of(context).colorScheme.onPrimary
                          : isWordDiscovered
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(shouldShow ? character.character : ''),
                  ),
                ),
              ),
            );
          }

          return InkWell(
            onTap: () {
              // Los cuadros vacíos también pueden ser interactivos
              // No hacer nada específico, pero permitir el feedback visual
            },
            child: ColoredBox(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
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
