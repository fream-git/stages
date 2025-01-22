import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stages/domain/entities/band.dart';

class BandRepository {
  final SharedPreferences _prefs;
  
  BandRepository(this._prefs);

  Future<List<Band>> loadBands(String eventId, DateTime date) async {
    final key = 'bands_${eventId}_${date.year}-${date.month}-${date.day}';
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => Band.fromMap(json as Map<String, dynamic>)).toList();
  }

  Future<void> saveBands(String eventId, DateTime date, List<Band> bands) async {
    final key = 'bands_${eventId}_${date.year}-${date.month}-${date.day}';
    final jsonList = bands.map((band) => band.toMap()).toList();
    await _prefs.setString(key, jsonEncode(jsonList));
  }
} 