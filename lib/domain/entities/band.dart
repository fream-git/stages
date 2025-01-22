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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'stageIndex': stageIndex,
    };
  }

  factory Band.fromMap(Map<String, dynamic> map) {
    return Band(
      id: map['id'],
      name: map['name'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      stageIndex: map['stageIndex'],
    );
  }
} 