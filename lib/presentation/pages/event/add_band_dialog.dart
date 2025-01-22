import 'package:flutter/material.dart';

class AddBandDialog extends StatefulWidget {
  final DateTime initialStartTime;
  final DateTime? initialEndTime;
  final String? initialName;

  const AddBandDialog({
    super.key,
    required this.initialStartTime,
    this.initialEndTime,
    this.initialName,
  });

  @override
  State<AddBandDialog> createState() => _AddBandDialogState();
}

class _AddBandDialogState extends State<AddBandDialog> {
  late TextEditingController _nameController;
  late DateTime _startTime;
  late DateTime _endTime;

  // Listen für Stunden und Minuten
  final List<int> _hours = List.generate(24, (i) => i + 8);  // 8-31 Uhr (8:00 bis 7:00 des nächsten Tages)
  final List<int> _minutes = List.generate(12, (i) => i * 5);  // 0-55 in 5er Schritten

  String _formatHour(int hour) {
    // Konvertiere Stunden > 23 in den nächsten Tag
    if (hour > 23) {
      return '${(hour - 24).toString().padLeft(2, '0')}';
    }
    return hour.toString().padLeft(2, '0');
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _startTime = widget.initialStartTime;
    _endTime = widget.initialEndTime ?? _startTime.add(const Duration(minutes: 30));
  }

  void _updateStartTime({int? hour, int? minute}) {
    setState(() {
      final isNextDay = hour != null && hour > 23;
      _startTime = DateTime(
        _startTime.year,
        _startTime.month,
        _startTime.day + (isNextDay ? 1 : 0),
        hour != null ? (hour % 24) : _startTime.hour,
        minute ?? _startTime.minute,
      );
      if (_endTime.isBefore(_startTime)) {
        _endTime = _startTime.add(const Duration(minutes: 30));
      }
    });
  }

  void _updateEndTime({int? hour, int? minute}) {
    final isNextDay = hour != null && hour > 23;
    final newEndTime = DateTime(
      _endTime.year,
      _endTime.month,
      _endTime.day + (isNextDay ? 1 : 0),
      hour != null ? (hour % 24) : _endTime.hour,
      minute ?? _endTime.minute,
    );
    if (newEndTime.isAfter(_startTime)) {
      setState(() {
        _endTime = newEndTime;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialName == null ? 'Band hinzufügen' : 'Band bearbeiten'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name der Band',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('Start'),
                      Row(
                        children: [
                          // Stunden
                          Expanded(
                            child: Column(
                              children: [
                                const Text('Std'),
                                SizedBox(
                                  height: 100,
                                  child: ListWheelScrollView(
                                    itemExtent: 40,
                                    diameterRatio: 1.5,
                                    useMagnifier: true,
                                    magnification: 1.2,
                                    physics: const FixedExtentScrollPhysics(),
                                    controller: FixedExtentScrollController(
                                      initialItem: _hours.indexOf(_startTime.hour),
                                    ),
                                    onSelectedItemChanged: (index) {
                                      _updateStartTime(hour: _hours[index]);
                                    },
                                    children: _hours.map((hour) {
                                      return Center(
                                        child: Text(
                                          _formatHour(hour),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Minuten
                          Expanded(
                            child: Column(
                              children: [
                                const Text('Min'),
                                SizedBox(
                                  height: 100,
                                  child: ListWheelScrollView(
                                    itemExtent: 40,
                                    diameterRatio: 1.5,
                                    useMagnifier: true,
                                    magnification: 1.2,
                                    physics: const FixedExtentScrollPhysics(),
                                    controller: FixedExtentScrollController(
                                      initialItem: _minutes.indexOf(_startTime.minute),
                                    ),
                                    onSelectedItemChanged: (index) {
                                      _updateStartTime(minute: _minutes[index]);
                                    },
                                    children: _minutes.map((minute) {
                                      return Center(
                                        child: Text(
                                          minute.toString().padLeft(2, '0'),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      const Text('Ende'),
                      Row(
                        children: [
                          // Stunden
                          Expanded(
                            child: Column(
                              children: [
                                const Text('Std'),
                                SizedBox(
                                  height: 100,
                                  child: ListWheelScrollView(
                                    itemExtent: 40,
                                    diameterRatio: 1.5,
                                    useMagnifier: true,
                                    magnification: 1.2,
                                    physics: const FixedExtentScrollPhysics(),
                                    controller: FixedExtentScrollController(
                                      initialItem: _hours.indexOf(_endTime.hour),
                                    ),
                                    onSelectedItemChanged: (index) {
                                      _updateEndTime(hour: _hours[index]);
                                    },
                                    children: _hours.map((hour) {
                                      return Center(
                                        child: Text(
                                          _formatHour(hour),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Minuten
                          Expanded(
                            child: Column(
                              children: [
                                const Text('Min'),
                                SizedBox(
                                  height: 100,
                                  child: ListWheelScrollView(
                                    itemExtent: 40,
                                    diameterRatio: 1.5,
                                    useMagnifier: true,
                                    magnification: 1.2,
                                    physics: const FixedExtentScrollPhysics(),
                                    controller: FixedExtentScrollController(
                                      initialItem: _minutes.indexOf(_endTime.minute),
                                    ),
                                    onSelectedItemChanged: (index) {
                                      _updateEndTime(minute: _minutes[index]);
                                    },
                                    children: _minutes.map((minute) {
                                      return Center(
                                        child: Text(
                                          minute.toString().padLeft(2, '0'),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bitte einen Namen eingeben'),
                ),
              );
              return;
            }
            Navigator.pop(context, {
              'name': _nameController.text,
              'startTime': _startTime,
              'endTime': _endTime,
            });
          },
          child: Text(widget.initialName == null ? 'Hinzufügen' : 'Speichern'),
        ),
      ],
    );
  }
} 