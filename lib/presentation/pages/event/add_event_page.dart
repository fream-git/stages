import 'package:flutter/material.dart';
import 'package:stages/domain/entities/event.dart';

/// Seite zum Hinzufügen eines neuen Events
class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Datum und Zeitraum
  bool _isDateRange = false;
  DateTime _selectedDate = DateTime.now();
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now().add(const Duration(days: 1)),
  );
  int _stages = 1;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Formatiert ein Datum als String
  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neues Event'),
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
            // Switch zwischen Einzeltag und Zeitraum
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
            // Datumsauswahl basierend auf Modus
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
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final event = Event.fromForm({
                    'title': _titleController.text,
                    'description': _descriptionController.text,
                    'isDateRange': _isDateRange,
                    'date': _isDateRange ? _selectedDateRange : _selectedDate,
                    'stages': _stages,
                  });
                  Navigator.pop(context, event);
                }
              },
              child: const Text('Event erstellen'),
            ),
          ],
        ),
      ),
    );
  }
} 