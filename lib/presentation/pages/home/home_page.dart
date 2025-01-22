import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stages/data/repositories/event_repository.dart';
import 'package:stages/domain/entities/event.dart';

/// Startseite der Anwendung
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Event> _events = [];
  late EventRepository _repository;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initRepository();
  }

  Future<void> _initRepository() async {
    final prefs = await SharedPreferences.getInstance();
    _repository = EventRepository(prefs);
    await _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await _repository.loadEvents();
    setState(() {
      _events.clear();
      _events.addAll(events);
      _isLoading = false;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Stages'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? const Center(child: Text('Noch keine Events vorhanden'))
              : ListView.builder(
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final event = _events[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/timeline',
                            arguments: event,
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: Text(event.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (event.description.isNotEmpty)
                                    Text(event.description),
                                  Row(
                                    children: [
                                      Text(
                                        event.isDateRange
                                            ? '${_formatDate(event.startDate)} - ${_formatDate(event.endDate!)}'
                                            : _formatDate(event.startDate),
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '• ${event.stages} ${event.stages == 1 ? 'Bühne' : 'Bühnen'}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  final result = await Navigator.pushNamed(
                                    context,
                                    '/edit-event',
                                    arguments: event,
                                  );
                                  
                                  if (result != null && context.mounted) {
                                    if (result == 'deleted') {
                                      await _repository.deleteEvent(event.id);
                                      setState(() {
                                        _events.removeWhere((e) => e.id == event.id);
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Event wurde gelöscht'),
                                        ),
                                      );
                                    } else {
                                      final updatedEvent = result as Event;
                                      await _repository.updateEvent(updatedEvent);
                                      setState(() {
                                        final index = _events.indexWhere((e) => e.id == event.id);
                                        if (index != -1) {
                                          _events[index] = updatedEvent;
                                        }
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Event wurde aktualisiert'),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_event'),
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            '/add-event',
          );
          
          if (result != null && context.mounted) {
            final event = result as Event;
            await _repository.addEvent(event);
            setState(() {
              _events.add(event);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Event wurde erstellt'),
              ),
            );
          }
        },
        tooltip: 'Event hinzufügen',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
} 