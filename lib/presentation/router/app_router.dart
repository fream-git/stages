import 'package:flutter/material.dart';
import 'package:stages/presentation/pages/home/home_page.dart';
import 'package:stages/presentation/pages/event/add_event_page.dart';
import 'package:stages/presentation/pages/event/edit_event_page.dart';
import 'package:stages/domain/entities/event.dart';
import 'package:stages/presentation/pages/event/timeline_page.dart';

/// Verwaltet die Navigation innerhalb der App
class AppRouter {
  /// Generiert Routen basierend auf den Einstellungen
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
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
          builder: (_) => TimelinePage(event: event),
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