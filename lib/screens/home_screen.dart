import 'package:flutter/material.dart';

import '../data/list_repository.dart';
import '../data/note_repository.dart';
import '../logic/notes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.clock = DateTime.now, this.repository});

  final DateTime Function() clock;

  /// Where notes are stored. Defaults to an in-memory store (tests); the app
  /// passes [deviceNoteRepository].
  final NoteRepository? repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Note> _notes = [];
  final _search = TextEditingController();
  String? _topic;
  int _nextId = 1;
  late final NoteRepository _repository =
      widget.repository ?? InMemoryListRepository<Note>();
  bool _loading = true;
  String? _storageError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final saved = await _repository.load();
      if (!mounted) return;
      setState(() {
        _notes
          ..clear()
          ..addAll(saved);
        _nextId = saved.fold(0, (m, n) => n.id > m ? n.id : m) + 1;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _storageError = 'Saved notes could not be read.';
      });
    }
  }

  Future<void> _persist() async {
    try {
      await _repository.save(List.of(_notes));
      if (mounted && _storageError != null) {
        setState(() => _storageError = null);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _storageError = 'Could not save notes on this device.');
    }
  }

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
    await _persist();
  }

  void _delete(Note note) {
    setState(() {
      _notes.remove(note);
      _syncTopic();
    });
    _persist();
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Deleted "${note.topic}" note'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            if (!mounted || _notes.contains(note)) return;
            setState(() => _notes.add(note));
            _persist();
          },
        ),
      ),
    );
  }

  /// Keeps the topic filter when another note still has that topic (in any
  /// letter case) and re-points it at the spelling shown on the chip.
  void _syncTopic() {
    final current = _topic;
    if (current == null) return;
    if (!hasTopic(_notes, current)) {
      _topic = null;
      return;
    }
    _topic = topicsOf(_notes).firstWhere(
      (t) => t.toLowerCase() == current.toLowerCase(),
    );
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
          if (_storageError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _storageError!,
                key: const Key('storage-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_notes.isEmpty)
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
              textInputAction: TextInputAction.next,
            ),
            TextField(
              key: const Key('topic-field'),
              controller: _topic,
              decoration: const InputDecoration(labelText: 'Topic'),
              textInputAction: TextInputAction.next,
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
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    _error!,
                    key: const Key('note-error'),
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
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
