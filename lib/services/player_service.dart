import 'package:built_collection/built_collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../interactive_providers.dart';
import '../model.dart';
import 'supabase_service.dart';

/// Servicio para gestionar jugadores con nombres automáticos
class PlayerService {
  static const String _playersKey = 'game_players';
  static const String _currentPlayerKey = 'current_player';
  static const String _nextPlayerNumberKey = 'next_player_number';

  /// Obtiene el siguiente número de jugador disponible
  static Future<int> _getNextPlayerNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_nextPlayerNumberKey) ?? 1;
  }

  /// Incrementa el contador de jugadores
  static Future<void> _incrementPlayerNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final current = await _getNextPlayerNumber();
    await prefs.setInt(_nextPlayerNumberKey, current + 1);
  }

  /// Genera el nombre automático para un nuevo jugador
  static Future<String> _generatePlayerName() async {
    final number = await _getNextPlayerNumber();
    return 'Player $number';
  }

  /// Guarda un jugador en SharedPreferences
  static Future<void> savePlayer(GameUser player) async {
    final prefs = await SharedPreferences.getInstance();
    final playersJson = prefs.getString(_playersKey) ?? '{}';
    final players = Map<String, dynamic>.from(json.decode(playersJson));

    players[player.username] = {
      'username': player.username,
      'bestScore': player.bestScore,
      'gamesCompleted': player.gamesCompleted,
      'lastPlayed': player.lastPlayed?.toIso8601String(),
    };

    await prefs.setString(_playersKey, json.encode(players));
  }

  /// Obtiene un jugador por nombre
  static Future<GameUser?> getPlayer(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final playersJson = prefs.getString(_playersKey) ?? '{}';
    final players = Map<String, dynamic>.from(json.decode(playersJson));

    final playerData = players[username];
    if (playerData == null) return null;

    return GameUser(
      (b) => b
        ..username = playerData['username']
        ..bestScore = playerData['bestScore']
        ..gamesCompleted = playerData['gamesCompleted']
        ..lastPlayed = playerData['lastPlayed'] != null
            ? DateTime.parse(playerData['lastPlayed'])
            : null,
    );
  }

  /// Obtiene todos los jugadores ordenados por mejor puntuación
  static Future<List<GameUser>> getAllPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final playersJson = prefs.getString(_playersKey) ?? '{}';
    final players = Map<String, dynamic>.from(json.decode(playersJson));

    final playerList = players.values.map((playerData) {
      return GameUser(
        (b) => b
          ..username = playerData['username']
          ..bestScore = playerData['bestScore']
          ..gamesCompleted = playerData['gamesCompleted']
          ..lastPlayed = playerData['lastPlayed'] != null
              ? DateTime.parse(playerData['lastPlayed'])
              : null,
      );
    }).toList();

    // Ordenar por mejor puntuación (menor es mejor)
    playerList.sort((a, b) {
      if (a.bestScore == 0) return 1;
      if (b.bestScore == 0) return -1;
      return a.bestScore.compareTo(b.bestScore);
    });

    return playerList;
  }

  /// Guarda el jugador actual
  static Future<void> setCurrentPlayer(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentPlayerKey, username);
  }

  /// Obtiene el jugador actual
  static Future<String?> getCurrentPlayerName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentPlayerKey);
  }

  /// Crea un nuevo jugador con nombre automático
  static Future<GameUser> createNewPlayer() async {
    final username = await _generatePlayerName();
    final player = GameUser.create(username);
    await savePlayer(player);
    await _incrementPlayerNumber();
    await setCurrentPlayer(username);

    // Sincronizar con Supabase si hay conexión
    await _syncPlayerToSupabase(player);

    return player;
  }

  /// Cambia al siguiente jugador (crea uno nuevo si no hay más)
  static Future<GameUser> switchToNextPlayer() async {
    final players = await getAllPlayers();
    final currentPlayerName = await getCurrentPlayerName();

    if (players.isEmpty) {
      return await createNewPlayer();
    }

    // Encontrar el índice del jugador actual
    final currentIndex = players.indexWhere(
      (p) => p.username == currentPlayerName,
    );

    // Cambiar al siguiente jugador o crear uno nuevo
    if (currentIndex == -1 || currentIndex >= players.length - 1) {
      // No hay jugador actual o es el último, crear uno nuevo
      return await createNewPlayer();
    } else {
      // Cambiar al siguiente jugador existente
      final nextPlayer = players[currentIndex + 1];
      await setCurrentPlayer(nextPlayer.username);
      return nextPlayer;
    }
  }

  /// Cambia a un jugador específico
  static Future<GameUser> switchToPlayer(String username) async {
    final player = await getPlayer(username);
    if (player == null) {
      throw Exception('Player not found: $username');
    }
    await setCurrentPlayer(username);
    return player;
  }

  /// Renombra un jugador
  static Future<GameUser> renamePlayer(String oldName, String newName) async {
    final player = await getPlayer(oldName);
    if (player == null) {
      throw Exception('Player not found: $oldName');
    }

    // Verificar que el nuevo nombre no exista ya
    final existingPlayer = await getPlayer(newName);
    if (existingPlayer != null) {
      throw Exception('Player name already exists: $newName');
    }

    // Crear jugador con nuevo nombre
    final renamedPlayer = player.rebuild((b) => b..username = newName);

    // Guardar con nuevo nombre
    await savePlayer(renamedPlayer);

    // Eliminar el antiguo
    await deletePlayer(oldName);

    // Si era el jugador actual, actualizar referencia
    final currentPlayer = await getCurrentPlayerName();
    if (currentPlayer == oldName) {
      await setCurrentPlayer(newName);
    }

    // Sincronizar con Supabase
    await _syncPlayerToSupabase(renamedPlayer);

    return renamedPlayer;
  }

  /// Elimina un jugador
  static Future<void> deletePlayer(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final playersJson = prefs.getString(_playersKey) ?? '{}';
    final players = Map<String, dynamic>.from(json.decode(playersJson));

    players.remove(username);
    await prefs.setString(_playersKey, json.encode(players));

    // Si era el jugador actual, limpiar
    final currentPlayer = await getCurrentPlayerName();
    if (currentPlayer == username) {
      await prefs.remove(_currentPlayerKey);
    }
  }

  /// Asegura que exista al menos un jugador (Player 1)
  static Future<GameUser> ensureDefaultPlayer() async {
    var currentPlayerName = await getCurrentPlayerName();

    if (currentPlayerName != null) {
      final player = await getPlayer(currentPlayerName);
      if (player != null) {
        return player;
      }
    }

    // No hay jugador actual válido, crear Player 1 o usar el primero disponible
    final players = await getAllPlayers();
    if (players.isNotEmpty) {
      await setCurrentPlayer(players.first.username);
      return players.first;
    }

    // No hay ningún jugador, crear Player 1
    return await createNewPlayer();
  }

  /// Sincroniza jugador con Supabase
  static Future<void> _syncPlayerToSupabase(GameUser player) async {
    try {
      if (await SupabaseService.hasInternetConnection()) {
        final supabase = SupabaseService.client;

        await supabase.from('game_users').upsert({
          'username': player.username,
          'best_score': player.bestScore,
          'games_completed': player.gamesCompleted,
          'last_played': player.lastPlayed?.toIso8601String(),
        });
      }
    } catch (e) {
      print('Error syncing player to Supabase: $e');
    }
  }

  /// Guarda una sesión de juego completada
  static Future<void> saveGameSession({
    required String username,
    required int score,
    required int wordsFound,
    required List<String> discoveredWords,
  }) async {
    try {
      if (await SupabaseService.hasInternetConnection()) {
        final supabase = SupabaseService.client;

        final userResponse = await supabase
            .from('game_users')
            .select('id')
            .eq('username', username)
            .single();

        final userId = userResponse['id'];

        final sessionResponse = await supabase
            .from('game_sessions')
            .insert({
              'user_id': userId,
              'words_found': wordsFound,
              'score': score,
            })
            .select('id')
            .single();

        final sessionId = sessionResponse['id'];

        if (discoveredWords.isNotEmpty) {
          await supabase
              .from('discovered_words_log')
              .insert(
                discoveredWords
                    .map((word) => {'session_id': sessionId, 'word': word})
                    .toList(),
              );
        }
      }
    } catch (e) {
      print('Error saving game session: $e');
    }
  }
}

/// Provider para el jugador actual
final currentPlayerProvider =
    StateNotifierProvider<CurrentPlayerNotifier, GameUser?>((ref) {
      return CurrentPlayerNotifier();
    });

class CurrentPlayerNotifier extends StateNotifier<GameUser?> {
  CurrentPlayerNotifier() : super(null) {
    _loadCurrentPlayer();
  }

  Future<void> _loadCurrentPlayer() async {
    state = await PlayerService.ensureDefaultPlayer();
  }

  Future<void> switchToNextPlayer() async {
    state = await PlayerService.switchToNextPlayer();
  }

  Future<void> switchToPlayer(String username) async {
    state = await PlayerService.switchToPlayer(username);
  }

  Future<void> updatePlayer(GameUser player) async {
    await PlayerService.savePlayer(player);
    state = player;
  }

  Future<void> renameCurrentPlayer(String newName) async {
    if (state != null) {
      state = await PlayerService.renamePlayer(state!.username, newName);
    }
  }
}

/// Provider para la sesión de juego actual
final gameSessionProvider =
    StateNotifierProvider<GameSessionNotifier, GameSession?>((ref) {
      final player = ref.watch(currentPlayerProvider);
      final targetWords = ref.watch(_targetWordsProvider);
      return GameSessionNotifier(player, targetWords);
    });

/// Provider interno que genera palabras objetivo
final _targetWordsProvider = StateProvider<BuiltSet<String>>(
  (ref) => BuiltSet<String>(),
);

class GameSessionNotifier extends StateNotifier<GameSession?> {
  GameSessionNotifier(this.player, this.targetWords) : super(null);

  final GameUser? player;
  final BuiltSet<String> targetWords;

  void startGame({BuiltSet<String>? newTargetWords}) {
    if (player != null) {
      state = GameSession.start(
        player!,
        targetWords: newTargetWords ?? targetWords,
      );
    }
  }

  void updateScore() {
    if (state != null && state!.isPlaying) {
      state = state!.updateScore();
    }
  }

  void incrementWordsFound() {
    if (state != null && state!.isPlaying) {
      state = state!.incrementWordsFound();
    }
  }

  void addFoundWord(String word, int points) {
    if (state != null && state!.isPlaying) {
      state = state!.addFoundWord(word, points);
    }
  }

  Future<void> finishGame(WidgetRef ref) async {
    if (state != null && state!.isPlaying) {
      state = state!.finishGame();
      await ref.read(currentPlayerProvider.notifier).updatePlayer(state!.user);

      final discoveredWords = ref.read(discoveredWordsProvider).toList();

      await PlayerService.saveGameSession(
        username: state!.user.username,
        score: state!.currentScore,
        wordsFound: state!.wordsFound,
        discoveredWords: discoveredWords,
      );
    }
  }

  void resetGame() {
    state = null;
  }
}
