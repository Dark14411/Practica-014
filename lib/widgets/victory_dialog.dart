import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model.dart';
import '../providers.dart' as app_providers;
import '../services/player_service.dart';

/// Diálogo que se muestra cuando el jugador gana (encuentra todas las palabras)
class VictoryDialog extends ConsumerWidget {
  final GameSession gameSession;

  const VictoryDialog({super.key, required this.gameSession});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minutes = gameSession.timeElapsed ~/ 60;
    final seconds = gameSession.timeElapsed % 60;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono de victoria
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events,
                size: 48,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 16),

            // Título
            Text(
              '¡Felicitaciones! 🎉',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtítulo
            Text(
              '¡Has completado el crucigrama!',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Estadísticas
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _StatRow(
                    icon: Icons.person,
                    label: 'Jugador',
                    value: gameSession.user.username,
                  ),
                  const Divider(height: 16),
                  _StatRow(
                    icon: Icons.timer,
                    label: 'Tiempo',
                    value: '${minutes}m ${seconds}s',
                  ),
                  const Divider(height: 16),
                  _StatRow(
                    icon: Icons.check_circle,
                    label: 'Palabras encontradas',
                    value: '${gameSession.wordsFound}',
                  ),
                  const Divider(height: 16),
                  _StatRow(
                    icon: Icons.star,
                    label: 'Puntuación',
                    value: '${gameSession.currentScore} pts',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Reiniciar sesión
                    ref.read(gameSessionProvider.notifier).resetGame();
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Cerrar'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _startNewGame(ref);
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('Jugar de nuevo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startNewGame(WidgetRef ref) {
    // Reiniciar sesión de juego
    ref.read(gameSessionProvider.notifier).resetGame();

    // Invalidar para generar nuevas palabras objetivo
    ref.invalidate(app_providers.workQueueProvider);
  }
}

/// Fila de estadística en el diálogo de victoria
class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

/// Función helper para mostrar el diálogo de victoria
void showVictoryDialog(BuildContext context, GameSession gameSession) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => VictoryDialog(gameSession: gameSession),
  );
}
