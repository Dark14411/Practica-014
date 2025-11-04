import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isPlaying = false;

  /// Inicializa y reproduce la música de fondo en loop
  static Future<void> initialize() async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(0.3); // 30% volumen
      await _player.play(AssetSource('music/background_music.mp3'));
      _isPlaying = true;
      debugPrint('🎵 Background music started');
    } catch (e) {
      debugPrint('❌ Error playing background music: $e');
    }
  }

  /// Pausa la música
  static Future<void> pause() async {
    if (_isPlaying) {
      await _player.pause();
      _isPlaying = false;
      debugPrint('⏸️  Music paused');
    }
  }

  /// Reanuda la música
  static Future<void> resume() async {
    if (!_isPlaying) {
      await _player.resume();
      _isPlaying = true;
      debugPrint('▶️  Music resumed');
    }
  }

  /// Detiene la música
  static Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
    debugPrint('⏹️  Music stopped');
  }

  /// Toggle música on/off
  static Future<void> toggle() async {
    if (_isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  /// Cambia el volumen (0.0 a 1.0)
  static Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Obtiene estado actual
  static bool get isPlaying => _isPlaying;

  /// Libera recursos
  static Future<void> dispose() async {
    await _player.dispose();
  }
}
