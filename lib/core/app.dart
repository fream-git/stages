import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:stages/presentation/router/app_router.dart';
import 'package:stages/presentation/theme/app_theme.dart';

/// Hauptanwendungsklasse, die das grundlegende Setup der App definiert
class StagesApp extends StatelessWidget {
  const StagesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stages',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de', ''),
      ],
      locale: const Locale('de'),
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
} 