import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stages/domain/entities/event.dart';
import 'package:stages/domain/entities/band.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // Immer die Live-API nutzen
  static const String baseUrl = 'https://www.froemelt.de/stages/api';
  static const String username = 'dein_username';  // Von deinem Hosting
  static const String password = 'dein_password';  // Von deinem Hosting

  // Events
  Future<List<Event>> getEvents() async {
    try {
      final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
      
      print('Fetching events from $baseUrl/events'); // Debug
      final response = await http.get(
        Uri.parse('$baseUrl/events'),
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
      );
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
      final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
      
      final response = await http.post(
        Uri.parse('$baseUrl/events'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth,
        },
        body: json.encode(event.toMap()),
      );
      
      print('Create response: ${response.statusCode}'); // Debug
      print('Create body: ${response.body}'); // Debug
      
      if (response.statusCode == 201) {
        return Event.fromMap(json.decode(response.body));
      }
      throw Exception('Failed to create event: ${response.statusCode}');
    } catch (e) {
      print('Error creating event: $e');
      rethrow;
    }
  }

  // Bands
  Future<List<Band>> getBands(String eventId, DateTime date) async {
    try {
      final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
      
      final response = await http.get(
        Uri.parse('$baseUrl/events/$eventId/bands/${date.toIso8601String()}'),
        headers: {
          'Authorization': basicAuth,
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Band.fromMap(json)).toList();
      }
      throw Exception('Failed to load bands: ${response.statusCode}');
    } catch (e) {
      print('Error loading bands: $e');
      rethrow;
    }
  }

  Future<void> saveBands(String eventId, DateTime date, List<Band> bands) async {
    try {
      final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
      
      print('🎸 Saving bands for event: $eventId'); // Emoji für bessere Sichtbarkeit
      print('📝 Band data: ${bands.map((b) => b.name).toList()}');
      
      final response = await http.put(
        Uri.parse('$baseUrl/events/$eventId/bands/${date.toIso8601String()}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth,
        },
        body: json.encode(bands.map((band) => band.toMap()).toList()),
      );
      
      print('📡 API Response: ${response.statusCode}');
      print('📦 Response body: ${response.body}');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to save bands: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error saving bands: $e');
      rethrow;
    }
  }
} 