import '../logic/notes.dart';
import 'list_repository.dart';

typedef NoteRepository = ListRepository<Note>;

/// Device storage for notes (shared_preferences, JSON).
const NoteRepository deviceNoteRepository =
    SharedPreferencesListRepository<Note>(
  storageKey: 'coursenotes_notes_v1',
  fromJson: Note.fromJson,
  toJson: noteToJson,
);
