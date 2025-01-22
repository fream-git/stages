import 'package:flutter/material.dart';
import 'package:stages/core/app.dart';
import 'package:stages/data/services/api_service.dart';
import 'package:stages/data/repositories/event_repository.dart';
import 'package:stages/data/repositories/band_repository.dart';

/// Haupteinstiegspunkt der Anwendung
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final apiService = ApiService();
  final eventRepository = EventRepository(apiService);
  final bandRepository = BandRepository(apiService);
  
  runApp(StagesApp(
    eventRepository: eventRepository,
    bandRepository: bandRepository,
  ));
} 