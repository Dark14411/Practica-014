import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../interactive_providers.dart';
import '../services/player_service.dart';

/// Widget que muestra las palabras objetivo que el jugador debe encontrar
class TargetWordsWidget extends ConsumerWidget {
  const TargetWordsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameSession = ref.watch(gameSessionProvider);
    final discoveredWords = ref.watch(discoveredWordsProvider);

    if (gameSession == null || !gameSession.isPlaying) {
      return const SizedBox.shrink();
    }

    final targetWords = gameSession.targetWords.toList();
    final foundCount = targetWords
        .where((word) => discoveredWords.contains(word.toLowerCase()))
        .length;

    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Palabras a Buscar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$foundCount/${targetWords.length}',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Progress bar
            LinearProgressIndicator(
              value: targetWords.isEmpty ? 0 : foundCount / targetWords.length,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 6,
            ),

            // Lista de palabras
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(12),
                itemCount: targetWords.length,
                itemBuilder: (context, index) {
                  final word = targetWords[index];
                  final isFound = discoveredWords.contains(word.toLowerCase());

                  return _WordItem(
                    word: word,
                    isFound: isFound,
                    index: index + 1,
                  );
                },
              ),
            ),

            // Footer con hint
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Toca las palabras de color azul fuerte',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WordItem extends StatelessWidget {
  final String word;
  final bool isFound;
  final int index;

  const _WordItem({
    required this.word,
    required this.isFound,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isFound ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isFound ? Colors.green : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Número de índice
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isFound ? Colors.green : Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Palabra
          Expanded(
            child: Text(
              word.toUpperCase(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: isFound ? FontWeight.bold : FontWeight.w500,
                color: isFound ? Colors.green.shade900 : Colors.black87,
                decoration: isFound ? TextDecoration.lineThrough : null,
                decorationColor: Colors.green,
                decorationThickness: 2,
              ),
            ),
          ),

          // Icono de check
          if (isFound)
            const Icon(Icons.check_circle, color: Colors.green, size: 24)
          else
            Icon(
              Icons.radio_button_unchecked,
              color: Colors.grey.shade400,
              size: 24,
            ),
        ],
      ),
    );
  }
}
