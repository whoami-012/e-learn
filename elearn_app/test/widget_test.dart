import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elearn_app/main.dart';
import 'package:elearn_app/providers/theme_provider.dart';

void main() {
  testWidgets('application bootstraps its MaterialApp', (tester) async {
    await tester.pumpWidget(const ELearnApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  test('theme provider supports light and dark initial modes', () {
    expect(
      ThemeProvider(loadPreference: false).themeMode,
      ThemeMode.light,
    );
    expect(
      ThemeProvider(initialDarkMode: true, loadPreference: false).themeMode,
      ThemeMode.dark,
    );
  });
}
