import 'package:flutter/material.dart' show DateTimeRange;

/// Repräsentiert ein Event in der Anwendung
class Event {
  final String id;
  final String title;
  final String description;
  final bool isDateRange;
  final DateTime startDate;
  final DateTime? endDate;
  final int stages;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.isDateRange,
    required this.startDate,
    this.endDate,
    required this.stages,
  });

  /// Erstellt ein Event aus den Formulardaten
  factory Event.fromForm(Map<String, dynamic> form) {
    final isDateRange = form['isDateRange'] as bool;
    final date = form['date'];
    
    return Event(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporäre ID-Generierung
      title: form['title'] as String,
      description: form['description'] as String,
      isDateRange: isDateRange,
      startDate: isDateRange ? (date as DateTimeRange).start : date as DateTime,
      endDate: isDateRange ? (date as DateTimeRange).end : null,
      stages: form['stages'] as int,
    );
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      isDateRange: map['is_date_range'] == '1' || map['is_date_range'] == 1,
      startDate: DateTime.parse(map['start_date']),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      stages: int.parse(map['stages'].toString()),
    );
  }

  /// Konvertiert das Event in eine Map für die Speicherung
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'is_date_range': isDateRange ? 1 : 0,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'stages': stages,
    };
  }
} 