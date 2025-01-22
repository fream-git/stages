import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stages/domain/entities/event.dart';
import 'package:stages/data/services/api_service.dart';

/// Repository für die Verwaltung von Events
class EventRepository {
  final ApiService _apiService;

  EventRepository(this._apiService);

  /// Lädt alle gespeicherten Events
  Future<List<Event>> loadEvents() async {
    return _apiService.getEvents();
  }

  /// Fügt ein neues Event hinzu
  Future<void> addEvent(Event event) async {
    await _apiService.createEvent(event);
  }

  /// Löscht ein Event
  Future<void> deleteEvent(String id) async {
    // TODO: Implementiere API-Aufruf für Löschen
    throw UnimplementedError('Delete noch nicht implementiert');
  }

  /// Aktualisiert ein Event
  Future<void> updateEvent(Event event) async {
    // TODO: Implementiere API-Aufruf für Update
    throw UnimplementedError('Update noch nicht implementiert');
  }
} 