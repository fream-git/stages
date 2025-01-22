import 'package:flutter/material.dart';
import 'package:stages/presentation/pages/home/home_page.dart';
import 'package:stages/presentation/pages/event/add_event_page.dart';
import 'package:stages/presentation/pages/event/edit_event_page.dart';
import 'package:stages/domain/entities/event.dart';
import 'package:stages/presentation/pages/event/timeline_page.dart';
import 'package:stages/data/repositories/event_repository.dart';
import 'package:stages/data/repositories/band_repository.dart';

/// Verwaltet die Navigation innerhalb der App
class AppRouter {
  /// Generiert Routen basierend auf den Einstellungen
  static Route<dynamic> onGenerateRoute(
    RouteSettings settings, {
    required EventRepository eventRepository,
    required BandRepository bandRepository,
  }) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => HomePage(eventRepository: eventRepository),
        );
      case '/add-event':
        return MaterialPageRoute(
          builder: (_) => const AddEventPage(),
        );
      case '/edit-event':
        final event = settings.arguments as Event;
        return MaterialPageRoute(
          builder: (_) => EditEventPage(event: event),
        );
      case '/timeline':
        final event = settings.arguments as Event;
        return MaterialPageRoute(
          builder: (_) => TimelinePage(
            event: event,
            bandRepository: bandRepository,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('404 - Seite nicht gefunden'),
            ),
          ),
        );
    }
  }
} 