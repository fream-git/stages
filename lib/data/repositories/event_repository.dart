import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stages/domain/entities/event.dart';

/// Repository für die Verwaltung von Events
class EventRepository {
  static const String _storageKey = 'events';
  final SharedPreferences _prefs;

  EventRepository(this._prefs);

  /// Lädt alle gespeicherten Events
  Future<List<Event>> loadEvents() async {
    final String? eventsJson = _prefs.getString(_storageKey);
    if (eventsJson == null) return [];

    final List<dynamic> eventsList = json.decode(eventsJson);
    return eventsList.map((eventMap) {
      return Event(
        id: eventMap['id'],
        title: eventMap['title'],
        description: eventMap['description'],
        isDateRange: eventMap['isDateRange'],
        startDate: DateTime.parse(eventMap['startDate']),
        endDate: eventMap['endDate'] != null 
            ? DateTime.parse(eventMap['endDate']) 
            : null,
        stages: eventMap['stages'] ?? 1, // Standardwert 1, falls nicht vorhanden
      );
    }).toList();
  }

  /// Speichert alle Events
  Future<void> saveEvents(List<Event> events) async {
    final List<Map<String, dynamic>> eventsList = 
        events.map((event) => event.toMap()).toList();
    await _prefs.setString(_storageKey, json.encode(eventsList));
  }

  /// Fügt ein neues Event hinzu
  Future<void> addEvent(Event event) async {
    final events = await loadEvents();
    events.add(event);
    await saveEvents(events);
  }

  /// Löscht ein Event
  Future<void> deleteEvent(String id) async {
    final events = await loadEvents();
    events.removeWhere((event) => event.id == id);
    await saveEvents(events);
  }

  /// Aktualisiert ein Event
  Future<void> updateEvent(Event event) async {
    final events = await loadEvents();
    final index = events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      events[index] = event;
      await saveEvents(events);
    }
  }
} 