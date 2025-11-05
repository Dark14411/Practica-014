import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/player_service.dart';
import '../model.dart';

class PlayerManagementScreen extends ConsumerStatefulWidget {
  const PlayerManagementScreen({super.key});

  @override
  ConsumerState<PlayerManagementScreen> createState() =>
      _PlayerManagementScreenState();
}

class _PlayerManagementScreenState
    extends ConsumerState<PlayerManagementScreen> {
  List<GameUser> _players = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    setState(() => _isLoading = true);
    final players = await PlayerService.getAllPlayers();
    setState(() {
      _players = players;
      _isLoading = false;
    });
  }

  Future<void> _createNewPlayer() async {
    final newPlayer = await PlayerService.createNewPlayer();
    await _loadPlayers();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${newPlayer.username} creado')));
    }
  }

  Future<void> _switchToPlayer(GameUser player) async {
    await ref
        .read(currentPlayerProvider.notifier)
        .switchToPlayer(player.username);
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cambiado a ${player.username}')));
    }
  }

  Future<void> _renamePlayer(GameUser player) async {
    final controller = TextEditingController(text: player.username);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renombrar Jugador'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nuevo nombre',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.of(context).pop(text);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (newName != null && newName != player.username) {
      try {
        await PlayerService.renamePlayer(player.username, newName);
        await _loadPlayers();

        // Actualizar el jugador actual si es el renombrado
        final currentPlayer = ref.read(currentPlayerProvider);
        if (currentPlayer?.username == player.username) {
          await ref
              .read(currentPlayerProvider.notifier)
              .switchToPlayer(newName);
        }

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Renombrado a $newName')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${e.toString().replaceAll('Exception: ', '')}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deletePlayer(GameUser player) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Jugador'),
        content: Text('¿Estás seguro de eliminar a ${player.username}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await PlayerService.deletePlayer(player.username);
      await _loadPlayers();

      // Si se eliminó el jugador actual, cambiar a otro
      final currentPlayer = ref.read(currentPlayerProvider);
      if (currentPlayer?.username == player.username) {
        final newPlayer = await PlayerService.ensureDefaultPlayer();
        await ref
            .read(currentPlayerProvider.notifier)
            .switchToPlayer(newPlayer.username);
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${player.username} eliminado')));
      }
    }
  }

  String _formatTime(int seconds) {
    if (seconds == 0) return 'Sin récord';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}m ${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    final currentPlayer = ref.watch(currentPlayerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Jugadores'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _players.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay jugadores',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _createNewPlayer,
                    icon: const Icon(Icons.add),
                    label: const Text('Crear Jugador'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadPlayers,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _players.length,
                itemBuilder: (context, index) {
                  final player = _players[index];
                  final isCurrentPlayer =
                      currentPlayer?.username == player.username;

                  return Card(
                    elevation: isCurrentPlayer ? 4 : 1,
                    color: isCurrentPlayer
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: isCurrentPlayer
                            ? Theme.of(context).colorScheme.primary
                            : Colors.blueGrey,
                        child: Text(
                          player.username[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              player.username,
                              style: TextStyle(
                                fontWeight: isCurrentPlayer
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCurrentPlayer) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'ACTUAL',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.emoji_events,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(_formatTime(player.bestScore)),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.games,
                                  size: 16,
                                  color: Colors.blueGrey,
                                ),
                                const SizedBox(width: 4),
                                Text('${player.gamesCompleted} juegos'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'switch':
                              _switchToPlayer(player);
                              break;
                            case 'rename':
                              _renamePlayer(player);
                              break;
                            case 'delete':
                              _deletePlayer(player);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          if (!isCurrentPlayer)
                            const PopupMenuItem(
                              value: 'switch',
                              child: Row(
                                children: [
                                  Icon(Icons.swap_horiz),
                                  SizedBox(width: 8),
                                  Text('Cambiar a este jugador'),
                                ],
                              ),
                            ),
                          const PopupMenuItem(
                            value: 'rename',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Renombrar'),
                              ],
                            ),
                          ),
                          if (_players.length > 1)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    'Eliminar',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      onTap: isCurrentPlayer
                          ? null
                          : () => _switchToPlayer(player),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewPlayer,
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo Jugador'),
      ),
    );
  }
}
