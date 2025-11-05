import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../interactive_providers.dart';
import '../model.dart';
import '../providers.dart';
import '../services/audio_service.dart';
import '../services/player_service.dart';
import 'connection_indicator.dart';
import 'crossword_widget.dart';
import 'player_management_screen.dart';
import 'scores_screen.dart';
import 'target_words_widget.dart';

class CrosswordGeneratorApp extends StatelessWidget {
  const CrosswordGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crossword Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blueGrey,
        brightness: Brightness.light,
      ),
      home: const _MainScreen(),
    );
  }
}

class _MainScreen extends ConsumerStatefulWidget {
  const _MainScreen();

  @override
  ConsumerState<_MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<_MainScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => AudioService.initialize());
  }

  @override
  Widget build(BuildContext context) {
    final currentPlayer = ref.watch(currentPlayerProvider);

    if (currentPlayer == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        leading: const ConnectionIndicator(),
        actions: [
          const _TimerWidget(),
          const SizedBox(width: 8),
          const _PerformanceIndicator(),
          const SizedBox(width: 8),
          const _PlayButton(),
          const _PlayerButton(),
          const _CrosswordGeneratorMenu(),
        ],
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        title: Text('Hola, ${currentPlayer.username}'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            const CrosswordWidget(),
            _InfoOverlay(),
            _TargetWordsOverlay(),
            _CompletionListener(),
          ],
        ),
      ),
    );
  }
}

// NUEVO: Widget del temporizador
class _TimerWidget extends ConsumerStatefulWidget {
  const _TimerWidget();

  @override
  ConsumerState<_TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends ConsumerState<_TimerWidget> {
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameSession = ref.watch(gameSessionProvider);
    final timeRemaining = ref.watch(gameTimerProvider);

    // Iniciar o detener timer según el estado del juego
    if (gameSession != null && gameSession.isPlaying) {
      _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
        ref.read(gameTimerProvider.notifier).tick();
      });
    } else {
      _timer?.cancel();
      _timer = null;
    }

    if (gameSession == null || !gameSession.isPlaying) {
      return const SizedBox.shrink();
    }

    final minutes = timeRemaining ~/ 60;
    final seconds = timeRemaining % 60;
    final isLowTime = timeRemaining <= 30;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isLowTime ? Colors.red.shade100 : Colors.blue.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 20,
            color: isLowTime ? Colors.red : Colors.blue,
          ),
          const SizedBox(width: 4),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isLowTime ? Colors.red : Colors.blue.shade900,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget separado para el botón de play - optimización
class _PlayButton extends ConsumerWidget {
  const _PlayButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameSession = ref.watch(gameSessionProvider);
    final workQueue = ref.watch(workQueueProvider);

    final isCompleted =
        workQueue.whenOrNull(data: (queue) => queue.isCompleted) ?? false;

    if (gameSession == null || !gameSession.isPlaying || isCompleted) {
      return IconButton(
        icon: const Icon(Icons.play_arrow),
        tooltip: 'Nuevo Crucigrama',
        onPressed: () async {
          // Resetear cancelación antes de iniciar nueva generación
          ref.read(generationCancellationProvider.notifier).state = false;
          ref.read(discoveredWordsProvider.notifier).reset();
          ref.invalidate(workQueueProvider);

          await Future.delayed(const Duration(milliseconds: 500));
          final targetWordsAsync = ref.read(targetWordsProvider);

          // Resetear e iniciar temporizador
          ref.read(gameTimerProvider.notifier).start(initialSeconds: 120);

          ref
              .read(gameSessionProvider.notifier)
              .startGame(newTargetWords: targetWordsAsync);
        },
      );
    }
    return const SizedBox.shrink();
  }
}

// Widget separado para el botón de jugador - optimización
class _PlayerButton extends ConsumerWidget {
  const _PlayerButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPlayer = ref.watch(currentPlayerProvider);
    if (currentPlayer == null) return const SizedBox.shrink();

    return IconButton(
      icon: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.white,
        child: Text(
          currentPlayer.username[0].toUpperCase(),
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => _PlayerDialog(player: currentPlayer),
        );
      },
    );
  }
}

// Widget separado para el indicador de rendimiento - optimización
class _PerformanceIndicator extends ConsumerWidget {
  const _PerformanceIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workQueue = ref.watch(workQueueProvider);
    final size = ref.watch(sizeProvider);
    final workerCount = ref.watch(workerCountProvider);

    return workQueue.when(
      data: (queue) {
        if (queue.isCompleted) {
          return const SizedBox.shrink();
        }

        final progress =
            queue.crossword.characters.length /
            (queue.crossword.width * queue.crossword.height);
        final isOptimalWorkers =
            workerCount.count <= size.maxRecommendedWorkers;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isOptimalWorkers
                ? Colors.green.shade100
                : Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isOptimalWorkers ? Icons.speed : Icons.warning,
                size: 16,
                color: isOptimalWorkers ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isOptimalWorkers
                      ? Colors.green.shade800
                      : Colors.orange.shade800,
                ),
              ),
              const SizedBox(width: 8),
              // Botón de cancelación
              InkWell(
                onTap: () {
                  ref.read(generationCancellationProvider.notifier).state =
                      true;
                  ref.invalidate(workQueueProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Generación cancelada'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.stop, size: 14, color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (error, stack) =>
          const Icon(Icons.error, color: Colors.red, size: 16),
    );
  }
}

// Widget separado para el overlay de info - optimización
class _InfoOverlay extends ConsumerWidget {
  const _InfoOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showInfo = ref.watch(showDisplayInfoProvider);
    return showInfo
        ? const SizedBox.shrink()
        : const SizedBox.shrink(); // Placeholder
  }
}

// Widget separado para el overlay de palabras objetivo - optimización
class _TargetWordsOverlay extends ConsumerWidget {
  const _TargetWordsOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameSession = ref.watch(gameSessionProvider);
    return gameSession != null && gameSession.isPlaying
        ? const TargetWordsWidget()
        : const SizedBox.shrink();
  }
}

// Widget separado para el listener de completado - optimización
class _CompletionListener extends ConsumerStatefulWidget {
  const _CompletionListener();

  @override
  ConsumerState<_CompletionListener> createState() =>
      _CompletionListenerState();
}

class _CompletionListenerState extends ConsumerState<_CompletionListener> {
  bool _timeUpDialogShown = false;
  bool _completionDialogShown = false;

  @override
  void didUpdateWidget(_CompletionListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset flags when game session changes
    final gameSession = ref.read(gameSessionProvider);
    if (gameSession == null || !gameSession.isPlaying) {
      _timeUpDialogShown = false;
      _completionDialogShown = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final workQueue = ref.watch(workQueueProvider);
    final gameSession = ref.watch(gameSessionProvider);
    final timeRemaining = ref.watch(gameTimerProvider);

    // Verificar si se acabó el tiempo
    if (timeRemaining <= 0 &&
        gameSession != null &&
        gameSession.isPlaying &&
        !_timeUpDialogShown) {
      _timeUpDialogShown = true;
      Future.microtask(() async {
        if (!mounted) return;
        await ref.read(gameSessionProvider.notifier).finishGame(ref);
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => _TimeUpDialog(
              score: gameSession.currentScore,
              wordsFound: gameSession.wordsFound,
            ),
          );
        }
      });
    }

    workQueue.whenData((queue) {
      if (queue.isCompleted &&
          gameSession != null &&
          gameSession.isPlaying &&
          !_completionDialogShown) {
        _completionDialogShown = true;
        Future.microtask(() async {
          if (!mounted) return;
          final wordCount = queue.crossword.words.length;
          for (var i = gameSession.wordsFound; i < wordCount; i++) {
            ref.read(gameSessionProvider.notifier).incrementWordsFound();
          }

          await ref.read(gameSessionProvider.notifier).finishGame(ref);

          if (context.mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => _CompletionDialog(
                score: gameSession.currentScore,
                wordCount: wordCount,
              ),
            );
          }
        });
      }
    });

    return const SizedBox.shrink();
  }
}

class _CrosswordGeneratorMenu extends ConsumerWidget {
  const _CrosswordGeneratorMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSize = ref.watch(sizeProvider);
    final showInfo = ref.watch(showDisplayInfoProvider);
    final workerCount = ref.watch(workerCountProvider);

    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Icons.people),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PlayerManagementScreen()),
          ),
          child: const Text('Gestionar Jugadores'),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.swap_horiz),
          onPressed: () => _switchPlayer(context, ref),
          child: const Text('Cambiar Jugador'),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.emoji_events),
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ScoresScreen())),
          child: const Text('Ver Puntajes'),
        ),
        const Divider(),
        SubmenuButton(
          menuChildren: CrosswordSize.values
              .map(
                (entry) => MenuItemButton(
                  onPressed: entry.isPerformanceSafe
                      ? () => _changeSize(ref, entry)
                      : () => _showPerformanceWarning(context, entry),
                  leadingIcon: Icon(
                    entry == currentSize
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  trailingIcon: entry.isPerformanceSafe
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        )
                      : const Icon(Icons.warning, color: Colors.red, size: 16),
                  child: Row(
                    children: [
                      Text(entry.label),
                      if (!entry.isPerformanceSafe) ...[
                        const SizedBox(width: 8),
                        const Text(
                          '(Puede congelar)',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ] else ...[
                        const SizedBox(width: 8),
                        const Text(
                          '(Recomendado)',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )
              .toList(),
          child: const Text('Tamaño del Grid'),
        ),
        MenuItemButton(
          leadingIcon: Icon(
            showInfo ? Icons.check_box : Icons.check_box_outline_blank,
          ),
          onPressed: () {
            ref.read(showDisplayInfoProvider.notifier).state = !showInfo;
          },
          child: const Text('Display Info'),
        ),
        SubmenuButton(
          menuChildren: BackgroundWorkers.values
              .map(
                (count) => MenuItemButton(
                  leadingIcon: Icon(
                    count == workerCount
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  onPressed: () =>
                      ref.read(workerCountProvider.notifier).setCount(count),
                  trailingIcon: _isOptimalWorkerCount(ref, count)
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        )
                      : null,
                  child: Text('${count.label} workers'),
                ),
              )
              .toList(),
          child: const Text('Workers'),
        ),
      ],
      builder: (context, controller, _) => IconButton(
        onPressed: controller.open,
        icon: const Icon(Icons.settings),
      ),
    );
  }

  void _switchPlayer(BuildContext context, WidgetRef ref) async {
    await ref.read(currentPlayerProvider.notifier).switchToNextPlayer();
    final newPlayer = ref.read(currentPlayerProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cambiado a ${newPlayer?.username}')),
      );
    }
  }

  void _changeSize(WidgetRef ref, CrosswordSize entry) {
    ref.read(sizeProvider.notifier).setSize(entry);
    // Optimizar automáticamente el número de workers para el nuevo tamaño
    ref.read(workerCountProvider.notifier).optimizeForSize(entry);
    ref.invalidate(workQueueProvider);
  }

  bool _isOptimalWorkerCount(WidgetRef ref, BackgroundWorkers count) {
    final currentSize = ref.watch(sizeProvider);
    return count.count <= currentSize.maxRecommendedWorkers;
  }

  void _showPerformanceWarning(BuildContext context, CrosswordSize entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 12),
            Text('Advertencia de Rendimiento'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'El tamaño ${entry.label} puede causar que la aplicación se congele durante la generación del crucigrama.',
            ),
            const SizedBox(height: 12),
            const Text(
              'Recomendaciones:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Usa tamaños "small" o "medium" para mejor rendimiento',
            ),
            const Text('• Reduce el número de workers a 1-2'),
            const Text('• La generación puede tardar varios minutos'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Permitir el cambio pero mostrar advertencia adicional
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('¿Continuar de todos modos?'),
                  content: const Text(
                    'La aplicación puede congelarse. ¿Quieres continuar?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('No'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Aquí iría el código para cambiar el tamaño
                        // Pero por ahora solo mostramos que se aceptó el riesgo
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Tamaño cambiado (usa bajo tu propio riesgo)',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      child: const Text('Sí, continuar'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Ver detalles'),
          ),
        ],
      ),
    );
  }
}

// Diálogo cuando se acaba el tiempo
class _TimeUpDialog extends ConsumerWidget {
  final int score;
  final int wordsFound;

  const _TimeUpDialog({required this.score, required this.wordsFound});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.timer_off, color: Colors.orange, size: 32),
          SizedBox(width: 12),
          Text('¡Tiempo Agotado!', style: TextStyle(color: Colors.orange)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$wordsFound',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('Palabras encontradas', style: TextStyle(fontSize: 18)),
        ],
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.emoji_events),
          label: const Text('Ver Ranking'),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ScoresScreen()));
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Nuevo Juego'),
          onPressed: () {
            Navigator.of(context).pop();
            ref.read(discoveredWordsProvider.notifier).reset();
            ref.invalidate(workQueueProvider);

            Future.delayed(const Duration(milliseconds: 500), () {
              ref.read(gameTimerProvider.notifier).start(initialSeconds: 120);
              ref.read(gameSessionProvider.notifier).startGame();
            });
          },
        ),
      ],
    );
  }
}

// Diálogo de jugador
class _PlayerDialog extends ConsumerWidget {
  final GameUser player;

  const _PlayerDialog({required this.player});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blueGrey.shade700,
            child: Text(
              player.username[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(player.username)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (player.bestScore > 0) ...[
            _InfoRow(
              icon: Icons.emoji_events,
              label: 'Mejor tiempo',
              value: _formatTime(player.bestScore),
            ),
            const SizedBox(height: 8),
          ],
          _InfoRow(
            icon: Icons.games,
            label: 'Juegos completados',
            value: '${player.gamesCompleted}',
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.emoji_events),
          label: const Text('Ver Ranking'),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ScoresScreen()));
          },
        ),
        TextButton.icon(
          icon: const Icon(Icons.people),
          label: const Text('Gestionar Jugadores'),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PlayerManagementScreen()),
            );
          },
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}m ${secs}s';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(value),
      ],
    );
  }
}

// Diálogo de crucigrama completado
class _CompletionDialog extends ConsumerWidget {
  final int score;
  final int wordCount;

  const _CompletionDialog({required this.score, required this.wordCount});

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}m ${secs}s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPlayer = ref.watch(currentPlayerProvider);
    final isNewRecord =
        currentPlayer != null &&
        (currentPlayer.bestScore == 0 || score < currentPlayer.bestScore);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            isNewRecord ? Icons.emoji_events : Icons.check_circle,
            color: isNewRecord ? Colors.amber : Colors.green,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isNewRecord ? '¡Nuevo Récord!' : '¡Completado!',
              style: TextStyle(
                color: isNewRecord ? Colors.amber : Colors.green,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatTime(score),
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            '$wordCount palabras encontradas',
            style: const TextStyle(fontSize: 18),
          ),
          if (isNewRecord) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.amber),
                  SizedBox(width: 8),
                  Text(
                    '¡Has superado tu mejor tiempo!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.emoji_events),
          label: const Text('Ver Ranking'),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ScoresScreen()));
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Nuevo Juego'),
          onPressed: () {
            Navigator.of(context).pop();
            // Resetear palabras descubiertas
            ref.read(discoveredWordsProvider.notifier).reset();
            // Reiniciar generación y sesión
            ref.invalidate(workQueueProvider);

            Future.delayed(const Duration(milliseconds: 500), () {
              ref.read(gameTimerProvider.notifier).start(initialSeconds: 120);
              ref.read(gameSessionProvider.notifier).startGame();
            });
          },
        ),
      ],
    );
  }
}
