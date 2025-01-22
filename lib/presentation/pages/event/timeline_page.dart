import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stages/domain/entities/event.dart';
import 'package:stages/domain/entities/band.dart';
import 'package:stages/presentation/pages/event/add_band_dialog.dart';
import 'package:stages/data/repositories/band_repository.dart';

/// Zeigt die Timeline eines Events an
class TimelinePage extends StatefulWidget {
  final Event event;
  final BandRepository bandRepository;

  const TimelinePage({
    super.key, 
    required this.event,
    required this.bandRepository,
  });

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  late DateTime _selectedDate;
  late List<DateTime> _eventDays;
  bool _isLoading = true;  // Neuer Loading-Status
  late List<String> _stageNames;  // Neue Variable für Bühnennamen
  final List<Band> _bands = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.event.startDate;
    _eventDays = _generateEventDays();
    _loadStageNames();
    _loadBands();
  }

  Future<void> _loadBands() async {
    try {
      final bands = await widget.bandRepository.loadBands(
        widget.event.id, 
        _selectedDate
      );
      setState(() {
        _bands.clear();
        _bands.addAll(bands);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveBands() async {
    await widget.bandRepository.saveBands(widget.event.id, _selectedDate, _bands);
  }

  Future<void> _loadStageNames() async {
    final prefs = await SharedPreferences.getInstance();
    final stageNames = <String>[];
    
    for (var i = 0; i < widget.event.stages; i++) {
      final name = prefs.getString('stage_name_${widget.event.id}_$i') ?? 'Bühne ${i + 1}';
      stageNames.add(name);
    }
    
    setState(() {
      _stageNames = stageNames;
    });
  }

  Future<void> _saveStageName(int index, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('stage_name_${widget.event.id}_$index', name);
    setState(() {
      _stageNames[index] = name;
    });
  }

  Future<void> _editStageName(BuildContext context, int index) async {
    final controller = TextEditingController(text: _stageNames[index]);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bühne umbenennen'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Name der Bühne',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Speichern'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await _saveStageName(index, result);
    }
  }

  Future<void> _loadSelectedDate() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDateMillis = prefs.getInt('selected_date_${widget.event.id}');
    
    if (savedDateMillis != null) {
      final savedDate = DateTime.fromMillisecondsSinceEpoch(savedDateMillis);
      if (_eventDays.any((date) => 
          date.year == savedDate.year && 
          date.month == savedDate.month && 
          date.day == savedDate.day)) {
        setState(() {
          _selectedDate = savedDate;
        });
      }
    }
  }

  Future<void> _saveSelectedDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_date_${widget.event.id}', date.millisecondsSinceEpoch);
  }

  List<DateTime> _generateEventDays() {
    if (!widget.event.isDateRange || widget.event.endDate == null) {
      return [widget.event.startDate];
    }

    final days = <DateTime>[];
    var currentDate = widget.event.startDate;
    final endDate = widget.event.endDate!;

    while (!currentDate.isAfter(endDate)) {
      days.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return days;
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  String _formatHour(int hour) {
    // Konvertiert die Stunde in 24-Stunden-Format
    final adjustedHour = (hour % 24);
    return '${adjustedHour.toString().padLeft(2, '0')}:00';
  }

  Future<void> _addBand(int stageIndex, int timeSlotIndex) async {
    final initialStartTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      8 + (timeSlotIndex ~/ 2),
      (timeSlotIndex % 2) * 30,
    );
    
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddBandDialog(
        initialStartTime: initialStartTime,
      ),
    );

    if (result != null) {
      final band = Band(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: result['name'] as String,
        startTime: result['startTime'] as DateTime,
        endTime: result['endTime'] as DateTime,
        stageIndex: stageIndex,
      );
      setState(() {
        _bands.add(band);
      });
      await _saveBands();
    }
  }

  Future<void> _editBand(Band band) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddBandDialog(
        initialName: band.name,
        initialStartTime: band.startTime,
        initialEndTime: band.endTime,
      ),
    );

    if (result != null) {
      setState(() {
        final index = _bands.indexWhere((b) => b.id == band.id);
        if (index != -1) {
          _bands[index] = band.copyWith(
            name: result['name'] as String,
            startTime: result['startTime'] as DateTime,
            endTime: result['endTime'] as DateTime,
          );
        }
      });
      await _saveBands();
    }
  }

  Future<void> _deleteBand(Band band) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Band löschen'),
        content: Text('Möchten Sie "${band.name}" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _bands.removeWhere((b) => b.id == band.id);
      });
      await _saveBands();
    }
  }

  @override
  Widget build(BuildContext context) {
    const double timeSlotHeight = 25.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Tagesauswahl (nur anzeigen wenn es mehrere Tage gibt)
          if (_eventDays.length > 1)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: _eventDays.map((date) {
                  final isSelected = date.year == _selectedDate.year &&
                      date.month == _selectedDate.month &&
                      date.day == _selectedDate.day;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(_formatDate(date)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedDate = date;
                          });
                          _saveSelectedDate(date);
                          _loadBands();  // Lade die Bands für das neue Datum
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

          // Event-Info Header mit Bühnenbezeichnungen
          Padding(
            padding: const EdgeInsets.only(left: 60.0), // Nur links Padding für Zeitstrahl-Breite
            child: Row(
              children: List.generate(
                widget.event.stages,
                (index) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 4.0, // Kleiner horizontaler Abstand zwischen Karten
                    ),
                    child: Card(
                      child: InkWell( // Hinzufügen von InkWell für Tap-Effekt
                        onTap: () => _editStageName(context, index),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            _stageNames[index], // Verwendung des gespeicherten Namens
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Timeline mit Bühnen
          Expanded(
            child: SingleChildScrollView(
              child: SizedBox(  // Definiere eine feste Höhe
                height: timeSlotHeight * 48,  // 48 Zeitslots à 25 Pixel
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Zeitstrahl
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Zeitslots
                        ...List.generate(48, (index) {
                          final isFullHour = index % 2 == 0;
                          final hour = (index ~/ 2) + 8;
                          
                          return Container(
                            width: 60,
                            height: timeSlotHeight,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Theme.of(context).dividerColor.withOpacity(
                                    isFullHour ? 0.3 : 0.8,
                                  ),
                                  width: isFullHour ? 1.0 : 2.0,
                                ),
                                right: BorderSide(color: Theme.of(context).dividerColor),
                              ),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 8.0),
                            child: isFullHour
                                ? Text(
                                    _formatHour(hour),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  )
                                : null,
                          );
                        }),
                      ],
                    ),
                    // Bühnen
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            children: [
                              // Basis-Zeitraster mit 5-Minuten-Slots
                              Column(
                                children: List.generate(48, (timeIndex) {
                                  final isFullHour = timeIndex % 2 == 0;
                                  return SizedBox(
                                    height: timeSlotHeight,
                                    child: Row(
                                      children: List.generate(
                                        widget.event.stages,
                                        (stageIndex) => Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Theme.of(context).dividerColor.withOpacity(
                                                    isFullHour ? 0.3 : 0.8,
                                                  ),
                                                  width: isFullHour ? 1.0 : 2.0,
                                                ),
                                                right: stageIndex < widget.event.stages - 1
                                                    ? BorderSide(color: Theme.of(context).dividerColor)
                                                    : BorderSide.none,
                                              ),
                                            ),
                                            // 6 DragTargets für 5-Minuten-Slots
                                            child: InkWell(
                                              onTap: () => _addBand(stageIndex, timeIndex),
                                              child: Container(
                                                height: timeSlotHeight,
                                                color: Colors.transparent,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              // Band-Karten
                              ..._bands.map((band) {
                                // Berechne die Position in 5-Minuten-Schritten
                                int startMinutes = (band.startTime.hour - 8) * 60 + band.startTime.minute;
                                int endMinutes = (band.endTime.hour - 8) * 60 + band.endTime.minute;
                                
                                // Korrektur für Zeiten nach Mitternacht
                                if (band.endTime.day > band.startTime.day) {
                                  // Wenn die Endzeit am nächsten Tag liegt, addiere die Minuten bis Mitternacht
                                  endMinutes = ((24 - 8) * 60) + (band.endTime.hour * 60) + band.endTime.minute;
                                }
                                
                                // Korrektur für frühe Morgenstunden (0-7 Uhr)
                                if (band.endTime.hour < 8 && band.endTime.day > band.startTime.day) {
                                  endMinutes = ((24 - 8) * 60) + (band.endTime.hour * 60) + band.endTime.minute;
                                }
                                
                                // Konvertiere Minuten in Position und Höhe
                                final topPosition = (startMinutes / 30) * timeSlotHeight;
                                final height = ((endMinutes - startMinutes) / 30) * timeSlotHeight;
                                
                                // Berechne die exakte Breite und Position
                                final columnWidth = constraints.maxWidth / widget.event.stages;
                                final leftPosition = columnWidth * band.stageIndex;
                                
                                return Positioned(
                                  top: topPosition,
                                  left: leftPosition,
                                  width: columnWidth,
                                  height: height,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple,
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(
                                        color: Colors.white24,
                                        width: 1,
                                      ),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8.0),
                                      onTap: () => _editBand(band),
                                      child: Container(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                band.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (height > timeSlotHeight)
                                              Text(
                                                '${_formatTime(band.startTime)} - ${_formatTime(band.endTime)}',
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 10,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
} 