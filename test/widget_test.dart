import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:generate_crossword/widgets/crossword_generator_app.dart';

void main() {
  testWidgets('Crossword app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: CrosswordGeneratorApp())),
    );

    // Verify that the app bar is present
    expect(find.text('Crossword Generator'), findsOneWidget);

    // Verify that settings menu icon is present
    expect(find.byIcon(Icons.settings), findsOneWidget);
  });
}
