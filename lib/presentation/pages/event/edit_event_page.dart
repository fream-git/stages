import 'package:flutter/material.dart';
import 'package:stages/domain/entities/event.dart';

/// Seite zum Bearbeiten eines Events
class EditEventPage extends StatefulWidget {
  final Event event;

  const EditEventPage({super.key, required this.event});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late bool _isDateRange;
  late DateTime _selectedDate;
  late DateTimeRange _selectedDateRange;
  late int _stages;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(text: widget.event.description);
    _isDateRange = widget.event.isDateRange;
    _selectedDate = widget.event.startDate;
    _selectedDateRange = DateTimeRange(
      start: widget.event.startDate,
      end: widget.event.endDate ?? widget.event.startDate,
    );
    _stages = widget.event.stages;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event bearbeiten'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titel',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte geben Sie einen Titel ein';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Beschreibung',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16.0),
            SwitchListTile(
              title: const Text('Zeitraum statt Einzeltag'),
              value: _isDateRange,
              onChanged: (bool value) {
                setState(() {
                  _isDateRange = value;
                });
              },
            ),
            const SizedBox(height: 8.0),
            if (!_isDateRange)
              ListTile(
                title: const Text('Datum'),
                subtitle: Text(_formatDate(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    locale: const Locale('de'),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
              )
            else
              ListTile(
                title: const Text('Zeitraum'),
                subtitle: Text(
                  '${_formatDate(_selectedDateRange.start)} - ${_formatDate(_selectedDateRange.end)}',
                ),
                trailing: const Icon(Icons.date_range),
                onTap: () async {
                  final DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    initialDateRange: _selectedDateRange,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    locale: const Locale('de'),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          appBarTheme: const AppBarTheme(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDateRange = picked;
                    });
                  }
                },
              ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Anzahl der Bühnen: $_stages',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: _stages > 1 
                      ? () => setState(() => _stages--) 
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                IconButton(
                  onPressed: _stages < 5 
                      ? () => setState(() => _stages++) 
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 32.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final updatedEvent = Event(
                          id: widget.event.id,
                          title: _titleController.text,
                          description: _descriptionController.text,
                          isDateRange: _isDateRange,
                          startDate: _isDateRange ? _selectedDateRange.start : _selectedDate,
                          endDate: _isDateRange ? _selectedDateRange.end : null,
                          stages: _stages,
                        );
                        Navigator.pop(context, updatedEvent);
                      }
                    },
                    child: const Text('Änderungen speichern'),
                  ),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Event löschen'),
                          content: const Text(
                            'Möchten Sie dieses Event wirklich löschen?'
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Dialog schließen
                              },
                              child: const Text('Abbrechen'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Dialog schließen
                                Navigator.pop(context, 'deleted'); // Zur HomePage zurück
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Löschen'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Icon(Icons.delete),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 