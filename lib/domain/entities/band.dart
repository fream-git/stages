class Band {
  final String id;
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final int stageIndex;

  Band({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.stageIndex,
  });

  Band copyWith({
    String? name,
    DateTime? startTime,
    DateTime? endTime,
    int? stageIndex,
  }) {
    return Band(
      id: id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      stageIndex: stageIndex ?? this.stageIndex,
    );
  }

  factory Band.fromMap(Map<String, dynamic> map) {
    return Band(
      id: map['id'],
      name: map['name'],
      startTime: DateTime.parse(map['start_time']),
      endTime: DateTime.parse(map['end_time']),
      stageIndex: map['stage_index'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'stage_index': stageIndex,
    };
  }
} 