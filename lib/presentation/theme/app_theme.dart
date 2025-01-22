import 'package:flutter/material.dart';

/// Definiert das visuelle Erscheinungsbild der App
class AppTheme {
  /// Helles Theme für die App
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
    );
  }

  /// Dunkles Theme für die App
  static ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.dark,
    );
  }
} 