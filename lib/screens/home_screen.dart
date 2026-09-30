import 'package:flutter/material.dart';

import '../logic/notes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.clock = DateTime.now});

  final DateTime Function() clock;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Note> _notes = [];
  final _search = TextEditingController();
  String? _topic;
  int _nextId = 1;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _addNote() async {
    final note = await showDialog<Note>(
      context: context,
      builder: (_) => _NoteDialog(id: _nextId, clock: widget.clock),
    );
    if (note == null) return;
    setState(() {
      _notes.add(note);
      _nextId++;
    });
  }

  void _delete(Note note) {
    setState(() {
      _notes.remove(note);
      if (_topic != null && !topicsOf(_notes).contains(_topic)) _topic = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final topics = topicsOf(_notes);
    final visible = searchNotes(_notes, query: _search.text, topic: _topic);
    return Scaffold(
      appBar: AppBar(title: const Text('Coursenotes')),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-note'),
        onPressed: _addNote,
        icon: const Icon(Icons.add),
        label: const Text('Add note'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        children: [
          TextField(
            key: const Key('search'),
            controller: _search,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Search notes',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          if (topics.isNotEmpty)
            Wrap(
              spacing: 8,
              children: [
                for (final t in topics)
                  FilterChip(
                    label: Text(t),
                    selected: _topic == t,
                    onSelected: (on) => setState(() => _topic = on ? t : null),
                  ),
              ],
            ),
          const SizedBox(height: 8),
          if (_notes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No notes yet. Tap "Add note" to write your first one.',
                textAlign: TextAlign.center,
              ),
            )
          else if (visible.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No notes match.', textAlign: TextAlign.center),
            ),
          for (final n in visible)
            Card(
              child: ListTile(
                title: Text('${n.course} · ${n.topic}'),
                subtitle: Text(n.body),
                trailing: IconButton(
                  tooltip: 'Delete note',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _delete(n),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NoteDialog extends StatefulWidget {
  const _NoteDialog({required this.id, required this.clock});

  final int id;
  final DateTime Function() clock;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  final _course = TextEditingController();
  final _topic = TextEditingController();
  final _body = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _course.dispose();
    _topic.dispose();
    _body.dispose();
    super.dispose();
  }

  void _save() {
    final error = validateNote(
      course: _course.text,
      topic: _topic.text,
      body: _body.text,
    );
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(
      Note(
        id: widget.id,
        course: _course.text,
        topic: _topic.text,
        body: _body.text,
        createdAt: widget.clock(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New note'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('course-field'),
              controller: _course,
              decoration: const InputDecoration(labelText: 'Course'),
            ),
            TextField(
              key: const Key('topic-field'),
              controller: _topic,
              decoration: const InputDecoration(labelText: 'Topic'),
            ),
            TextField(
              key: const Key('body-field'),
              controller: _body,
              decoration: const InputDecoration(labelText: 'Note'),
              minLines: 3,
              maxLines: 6,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('save-note'),
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
