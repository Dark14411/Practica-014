import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'services/supabase_service.dart';
import 'widgets/crossword_generator_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Supabase
  await SupabaseService.initialize();

  runApp(const ProviderScope(child: CrosswordGeneratorApp()));
}
