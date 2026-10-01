/// Pure note model and search/filter helpers.
library;

import 'package:characters/characters.dart';

const noteBodyMax = 5000;

class Note {
  Note({
    required this.id,
    required String course,
    required String topic,
    required String body,
    required this.createdAt,
  })  : course = course.trim(),
        topic = topic.trim(),
        body = body.trim();

  final int id;
  final String course;
  final String topic;
  final String body;
  final DateTime createdAt;

  Map<String, Object?> toJson() => {
        'id': id,
        'course': course,
        'topic': topic,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
      };

  static Note fromJson(Map<String, Object?> json) => Note(
        id: json['id'] as int,
        course: json['course'] as String,
        topic: json['topic'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

Map<String, Object?> noteToJson(Note note) => note.toJson();

String? validateNote({
  required String course,
  required String topic,
  required String body,
}) {
  if (course.trim().isEmpty) return 'Course is required';
  if (topic.trim().isEmpty) return 'Topic is required';
  if (body.trim().isEmpty) return 'Note text is required';
  // Count grapheme clusters so emoji and Thai combining marks count once.
  if (body.trim().characters.length > noteBodyMax) {
    return 'Note must be at most $noteBodyMax characters';
  }
  return null;
}

/// Distinct topics (case-insensitive, first spelling wins), sorted A-Z.
List<String> topicsOf(Iterable<Note> notes) {
  final seen = <String, String>{};
  for (final n in notes) {
    seen.putIfAbsent(n.topic.toLowerCase(), () => n.topic);
  }
  final list = seen.values.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return list;
}

/// Filters by optional [topic] (case-insensitive) and a free-text [query]
/// where every whitespace-separated term must appear in course, topic or body.
/// Results are newest first.
List<Note> searchNotes(Iterable<Note> notes,
    {String query = '', String? topic}) {
  final terms = query
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty)
      .toList();
  final wantedTopic = topic?.toLowerCase();
  final result = notes.where((n) {
    if (wantedTopic != null && n.topic.toLowerCase() != wantedTopic) {
      return false;
    }
    final haystack = '${n.course}\n${n.topic}\n${n.body}'.toLowerCase();
    return terms.every(haystack.contains);
  }).toList()
    ..sort((a, b) {
      final c = b.createdAt.compareTo(a.createdAt);
      return c != 0 ? c : b.id.compareTo(a.id);
    });
  return result;
}

/// Whether [topic] is still one of the topics in [notes] (case-insensitive),
/// so an active filter survives deleting the note that set its spelling.
bool hasTopic(Iterable<Note> notes, String topic) {
  final wanted = topic.toLowerCase();
  return notes.any((n) => n.topic.toLowerCase() == wanted);
}
