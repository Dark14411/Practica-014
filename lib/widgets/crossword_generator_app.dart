import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../interactive_providers.dart';
import '../model.dart';
import '../providers.dart';
import '../services/audio_service.dart';
import '../services/user_service.dart';
import 'connection_indicator.dart';
import 'crossword_info_widget.dart';
import 'crossword_widget.dart';
import 'login_screen.dart';
import 'scores_screen.dart';

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
  bool _musicInitialized = false;

  @override
  Widget build(BuildContext context) {
    return _EagerInitialization(
      child: Consumer(
        builder: (context, ref, _) {
          final currentUser = ref.watch(currentUserProvider);

          // Si no hay usuario, mostrar login
          if (currentUser == null) {
            _musicInitialized = false;
            return const LoginScreen();
          }

          // Iniciar música solo una vez cuando el usuario está logueado
          if (!_musicInitialized) {
            _musicInitialized = true;
            Future.microtask(() => AudioService.initialize());
          }

          // Usuario logueado, mostrar app normal
          return Scaffold(
            appBar: AppBar(
              leading: const ConnectionIndicator(),
              actions: [
                // Botón para iniciar juego/nuevo crucigrama
                Consumer(
                  builder: (context, ref, _) {
                    final gameSession = ref.watch(gameSessionProvider);
                    final workQueue = ref.watch(workQueueProvider);

                    final isCompleted =
                        workQueue.whenOrNull(
                          data: (queue) => queue.isCompleted,
                        ) ??
                        false;

                    if (gameSession == null ||
                        !gameSession.isPlaying ||
                        isCompleted) {
                      return IconButton(
                        icon: const Icon(Icons.play_arrow),
                        tooltip: 'Nuevo Crucigrama',
                        onPressed: () {
                          // Resetear palabras descubiertas
                          ref.read(discoveredWordsProvider.notifier).reset();
                          // Reiniciar generación
                          ref.invalidate(workQueueProvider);
                          // Iniciar nueva sesión
                          ref.read(gameSessionProvider.notifier).startGame();
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                // Botón de usuario
                IconButton(
                  icon: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: Text(
                      currentUser.username[0].toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => _UserDialog(user: currentUser),
                    );
                  },
                ),
                const _CrosswordGeneratorMenu(),
              ],
              titleTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              title: Text('Hola, ${currentUser.username}'),
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  const CrosswordWidget(),
                  Consumer(
                    builder: (context, ref, _) {
                      final showInfo = ref.watch(showDisplayInfoProvider);
                      if (showInfo) {
                        return const CrosswordInfoWidget();
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  // Listener para detectar crucigrama completado
                  Consumer(
                    builder: (context, ref, _) {
                      final workQueue = ref.watch(workQueueProvider);
                      final gameSession = ref.watch(gameSessionProvider);

                      workQueue.whenData((queue) {
                        if (queue.isCompleted &&
                            gameSession != null &&
                            gameSession.isPlaying) {
                          // Actualizar palabras encontradas
                          final wordCount = queue.crossword.words.length;
                          for (
                            var i = gameSession.wordsFound;
                            i < wordCount;
                            i++
                          ) {
                            ref
                                .read(gameSessionProvider.notifier)
                                .incrementWordsFound();
                          }

                          // Finalizar sesión
                          Future.microtask(() async {
                            await ref
                                .read(gameSessionProvider.notifier)
                                .finishGame(ref);

                            // Mostrar diálogo de felicitaciones
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
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EagerInitialization extends ConsumerWidget {
  const _EagerInitialization({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(wordListProvider);
    return child;
  }
}

class _CrosswordGeneratorMenu extends ConsumerWidget {
  const _CrosswordGeneratorMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) => MenuAnchor(
    menuChildren: [
      // Opción de Scores
      MenuItemButton(
        leadingIcon: const Icon(Icons.emoji_events),
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ScoresScreen()));
        },
        child: const Text('Ver Puntajes'),
      ),
      const Divider(),
      for (final entry in CrosswordSize.values)
        MenuItemButton(
          onPressed: () => ref.read(sizeProvider.notifier).setSize(entry),
          leadingIcon: entry == ref.watch(sizeProvider)
              ? const Icon(Icons.radio_button_checked_outlined)
              : const Icon(Icons.radio_button_unchecked_outlined),
          child: Text(entry.label),
        ),
      MenuItemButton(
        leadingIcon: ref.watch(showDisplayInfoProvider)
            ? const Icon(Icons.check_box_outlined)
            : const Icon(Icons.check_box_outline_blank_outlined),
        onPressed: () => ref.read(showDisplayInfoProvider.notifier).state = !ref
            .read(showDisplayInfoProvider),
        child: const Text('Display Info'),
      ),
      for (final count in BackgroundWorkers.values)
        MenuItemButton(
          leadingIcon: count == ref.watch(workerCountProvider)
              ? const Icon(Icons.radio_button_checked_outlined)
              : const Icon(Icons.radio_button_unchecked_outlined),
          onPressed: () =>
              ref.read(workerCountProvider.notifier).setCount(count),
          child: Text(count.label),
        ),
    ],
    builder: (context, controller, child) => IconButton(
      onPressed: () => controller.open(),
      icon: const Icon(Icons.settings),
    ),
  );
}

// Diálogo de usuario
class _UserDialog extends ConsumerWidget {
  final GameUser user;

  const _UserDialog({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blueGrey.shade700,
            child: Text(
              user.username[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(user.username)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user.bestScore > 0) ...[
            _InfoRow(
              icon: Icons.emoji_events,
              label: 'Mejor tiempo',
              value: _formatTime(user.bestScore),
            ),
            const SizedBox(height: 8),
          ],
          _InfoRow(
            icon: Icons.games,
            label: 'Juegos completados',
            value: '${user.gamesCompleted}',
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
          icon: const Icon(Icons.swap_horiz),
          label: const Text('Cambiar Usuario'),
          onPressed: () async {
            await ref.read(currentUserProvider.notifier).logout();
            if (context.mounted) {
              Navigator.of(context).pop();
            }
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
    final currentUser = ref.watch(currentUserProvider);
    final isNewRecord =
        currentUser != null &&
        (currentUser.bestScore == 0 || score < currentUser.bestScore);

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
                color: Colors.amber.withOpacity(0.1),
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
            ref.read(gameSessionProvider.notifier).startGame();
          },
        ),
      ],
    );
  }
}
