import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:stages/presentation/router/app_router.dart';
import 'package:stages/presentation/theme/app_theme.dart';
import 'package:stages/data/repositories/event_repository.dart';
import 'package:stages/data/repositories/band_repository.dart';

/// Hauptanwendungsklasse, die das grundlegende Setup der App definiert
class StagesApp extends StatelessWidget {
  final EventRepository eventRepository;
  final BandRepository bandRepository;

  const StagesApp({
    super.key, 
    required this.eventRepository,
    required this.bandRepository,
  });

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
      onGenerateRoute: (settings) => AppRouter.onGenerateRoute(
        settings,
        eventRepository: eventRepository,
        bandRepository: bandRepository,
      ),
    );
  }
} 