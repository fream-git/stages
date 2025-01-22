// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stages/core/app.dart';

void main() {
  testWidgets('App startet und zeigt Willkommenstext', (WidgetTester tester) async {
    // App aufbauen
    await tester.pumpWidget(const StagesApp());

    // Überprüfen ob der Willkommenstext vorhanden ist
    expect(find.text('Willkommen bei Stages'), findsOneWidget);
  });
}
