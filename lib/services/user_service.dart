import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../interactive_providers.dart';
import '../model.dart';
import 'supabase_service.dart';

/// Servicio para gestionar usuarios
class UserService {
  static const String _usersKey = 'game_users';
  static const String _currentUserKey = 'current_user';

  /// Guarda un usuario en SharedPreferences
  static Future<void> saveUser(GameUser user) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey) ?? '{}';
    final users = Map<String, dynamic>.from(json.decode(usersJson));

    users[user.username] = {
      'username': user.username,
      'bestScore': user.bestScore,
      'gamesCompleted': user.gamesCompleted,
      'lastPlayed': user.lastPlayed?.toIso8601String(),
    };

    await prefs.setString(_usersKey, json.encode(users));
  }

  /// Obtiene un usuario por nombre
  static Future<GameUser?> getUser(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey) ?? '{}';
    final users = Map<String, dynamic>.from(json.decode(usersJson));

    final userData = users[username];
    if (userData == null) return null;

    return GameUser(
      (b) => b
        ..username = userData['username']
        ..bestScore = userData['bestScore']
        ..gamesCompleted = userData['gamesCompleted']
        ..lastPlayed = userData['lastPlayed'] != null
            ? DateTime.parse(userData['lastPlayed'])
            : null,
    );
  }

  /// Obtiene todos los usuarios
  static Future<List<GameUser>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey) ?? '{}';
    final users = Map<String, dynamic>.from(json.decode(usersJson));

    return users.values.map((userData) {
      return GameUser(
        (b) => b
          ..username = userData['username']
          ..bestScore = userData['bestScore']
          ..gamesCompleted = userData['gamesCompleted']
          ..lastPlayed = userData['lastPlayed'] != null
              ? DateTime.parse(userData['lastPlayed'])
              : null,
      );
    }).toList();
  }

  /// Guarda el usuario actual
  static Future<void> setCurrentUser(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, username);
  }

  /// Obtiene el usuario actual
  static Future<String?> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  /// Crea o actualiza un usuario
  static Future<GameUser> createOrUpdateUser(String username) async {
    var user = await getUser(username);
    if (user == null) {
      user = GameUser.create(username);
      await saveUser(user);
    }
    await setCurrentUser(username);

    // Sincronizar con Supabase si hay conexión
    await _syncUserToSupabase(user);

    return user;
  }

  /// Sincroniza usuario con Supabase
  static Future<void> _syncUserToSupabase(GameUser user) async {
    try {
      if (await SupabaseService.hasInternetConnection()) {
        final supabase = SupabaseService.client;

        // Insertar o actualizar usuario
        await supabase.from('game_users').upsert({
          'username': user.username,
          'best_score': user.bestScore,
          'games_completed': user.gamesCompleted,
          'last_played': user.lastPlayed?.toIso8601String(),
        });
      }
    } catch (e) {
      // Ignorar errores de sincronización
      print('Error syncing user to Supabase: $e');
    }
  }

  /// Guarda una sesión de juego completada en Supabase
  static Future<void> saveGameSession({
    required String username,
    required int score,
    required int wordsFound,
    required List<String> discoveredWords,
  }) async {
    try {
      if (await SupabaseService.hasInternetConnection()) {
        final supabase = SupabaseService.client;

        // Obtener ID del usuario
        final userResponse = await supabase
            .from('game_users')
            .select('id')
            .eq('username', username)
            .single();

        final userId = userResponse['id'];

        // Insertar sesión
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

        // Insertar palabras descubiertas
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

/// Provider para el usuario actual
final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, GameUser?>((ref) {
      return CurrentUserNotifier();
    });

class CurrentUserNotifier extends StateNotifier<GameUser?> {
  CurrentUserNotifier() : super(null) {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final username = await UserService.getCurrentUsername();
    if (username != null) {
      state = await UserService.getUser(username);
    }
  }

  Future<void> login(String username) async {
    state = await UserService.createOrUpdateUser(username);
  }

  Future<void> logout() async {
    state = null;
  }

  Future<void> updateUser(GameUser user) async {
    await UserService.saveUser(user);
    state = user;
  }
}

/// Provider para la sesión de juego actual
final gameSessionProvider =
    StateNotifierProvider<GameSessionNotifier, GameSession?>((ref) {
      final user = ref.watch(currentUserProvider);
      return GameSessionNotifier(user);
    });

class GameSessionNotifier extends StateNotifier<GameSession?> {
  GameSessionNotifier(this.user) : super(null);

  final GameUser? user;

  void startGame() {
    if (user != null) {
      state = GameSession.start(user!);
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

  Future<void> finishGame(WidgetRef ref) async {
    if (state != null && state!.isPlaying) {
      state = state!.finishGame();
      // Actualizar usuario con nuevo score
      await ref.read(currentUserProvider.notifier).updateUser(state!.user);

      // Obtener palabras descubiertas
      final discoveredWords = ref.read(discoveredWordsProvider).toList();

      // Guardar sesión en Supabase
      await UserService.saveGameSession(
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
