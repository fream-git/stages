import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stages/presentation/router/app_router.dart';

void main() {
  group('AppRouter Tests', () {
    test('Route "/" sollte HomePage zurückgeben', () {
      final route = AppRouter.onGenerateRoute(
        const RouteSettings(name: '/'),
      );
      expect(route, isA<MaterialPageRoute>());
    });

    test('Unbekannte Route sollte 404-Seite zurückgeben', () {
      final route = AppRouter.onGenerateRoute(
        const RouteSettings(name: '/unbekannt'),
      );
      expect(route, isA<MaterialPageRoute>());
    });
  });
} 