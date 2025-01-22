import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stages/domain/entities/event.dart';
import 'package:stages/domain/entities/band.dart';

class ApiService {
  static const String baseUrl = 'https://www.froemelt.de/stages/api'; // Pfad zu deinem PHP-Backend

  // Events
  Future<List<Event>> getEvents() async {
    try {
      print('Fetching events from $baseUrl/events'); // Debug
      final response = await http.get(Uri.parse('$baseUrl/events'));
      print('Response status: ${response.statusCode}'); // Debug
      print('Response body: ${response.body}'); // Debug
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Event.fromMap(json)).toList();
      }
      throw Exception('Failed to load events: ${response.statusCode}');
    } catch (e) {
      print('Error loading events: $e'); // Debug
      rethrow;
    }
  }

  Future<Event> createEvent(Event event) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(event.toMap()),
      );
      
      if (response.statusCode == 201) {
        return Event.fromMap(json.decode(response.body));
      }
      
      print('Server response: ${response.body}'); // Debug-Ausgabe
      throw Exception('Failed to create event: ${response.statusCode}');
    } catch (e) {
      print('Error creating event: $e'); // Debug-Ausgabe
      rethrow;
    }
  }

  // Bands
  Future<List<Band>> getBands(String eventId, DateTime date) async {
    final response = await http.get(
      Uri.parse('$baseUrl/events/$eventId/bands/${date.toIso8601String()}'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Band.fromMap(json)).toList();
    }
    throw Exception('Failed to load bands');
  }

  Future<void> saveBands(String eventId, DateTime date, List<Band> bands) async {
    final response = await http.put(
      Uri.parse('$baseUrl/events/$eventId/bands/${date.toIso8601String()}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(bands.map((band) => band.toMap()).toList()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to save bands');
    }
  }
} 