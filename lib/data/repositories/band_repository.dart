import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stages/domain/entities/band.dart';
import 'package:stages/data/services/api_service.dart';

class BandRepository {
  final ApiService _apiService;
  
  BandRepository(this._apiService);

  Future<List<Band>> loadBands(String eventId, DateTime date) async {
    return _apiService.getBands(eventId, date);
  }

  Future<void> saveBands(String eventId, DateTime date, List<Band> bands) async {
    await _apiService.saveBands(eventId, date, bands);
  }
} 