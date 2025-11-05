import 'package:built_collection/built_collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider que rastrea qué palabras han sido descubiertas por el usuario
final discoveredWordsProvider =
    StateNotifierProvider<DiscoveredWordsNotifier, BuiltSet<String>>((ref) {
      return DiscoveredWordsNotifier();
    });

class DiscoveredWordsNotifier extends StateNotifier<BuiltSet<String>> {
  DiscoveredWordsNotifier() : super(BuiltSet<String>());

  void discoverWord(String word) {
    state = state.rebuild((b) => b.add(word.toLowerCase()));
  }

  void reset() {
    state = BuiltSet<String>();
  }

  bool isDiscovered(String word) {
    return state.contains(word.toLowerCase());
  }
}

/// Provider que indica si el crucigrama está en modo interactivo (oculto)
final interactiveModeProvider = StateProvider<bool>(
  (ref) => true,
); // Activado por defecto - las letras están ocultas hasta hacer clic
