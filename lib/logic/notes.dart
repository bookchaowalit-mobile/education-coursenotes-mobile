/// Pure note model and search/filter helpers.
library;

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
}

String? validateNote({
  required String course,
  required String topic,
  required String body,
}) {
  if (course.trim().isEmpty) return 'Course is required';
  if (topic.trim().isEmpty) return 'Topic is required';
  if (body.trim().isEmpty) return 'Note text is required';
  if (body.trim().length > 5000) return 'Note must be at most 5000 characters';
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
