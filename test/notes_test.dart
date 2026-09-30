import 'package:coursenotes/logic/notes.dart';
import 'package:flutter_test/flutter_test.dart';

Note _n(int id, String course, String topic, String body) => Note(
      id: id,
      course: course,
      topic: topic,
      body: body,
      createdAt: DateTime(2026, 1, id),
    );

void main() {
  final notes = [
    _n(1, 'CS101', 'Recursion', 'Base case first, then the recursive step.'),
    _n(2, 'MATH201', 'Limits', 'Squeeze theorem for bounded functions.'),
    _n(3, 'CS101', 'recursion', 'Tail calls can be optimised.'),
  ];

  test('validateNote requires every field', () {
    expect(validateNote(course: '', topic: 't', body: 'b'), contains('Course'));
    expect(validateNote(course: 'c', topic: ' ', body: 'b'), contains('Topic'));
    expect(validateNote(course: 'c', topic: 't', body: ''), contains('Note'));
    expect(validateNote(course: 'c', topic: 't', body: 'b'), isNull);
  });

  test('topicsOf is case-insensitive and sorted', () {
    expect(topicsOf(notes), ['Limits', 'Recursion']);
  });

  test('search matches all terms across fields, newest first', () {
    expect(searchNotes(notes).map((n) => n.id), [3, 2, 1]);
    expect(searchNotes(notes, query: 'cs101').map((n) => n.id), [3, 1]);
    expect(searchNotes(notes, query: 'cs101 tail').map((n) => n.id), [3]);
    expect(searchNotes(notes, query: 'SQUEEZE').map((n) => n.id), [2]);
    expect(searchNotes(notes, query: 'nothing-here'), isEmpty);
  });

  test('topic filter is case-insensitive', () {
    expect(
      searchNotes(notes, topic: 'Recursion').map((n) => n.id),
      [3, 1],
    );
    expect(
      searchNotes(notes, topic: 'recursion', query: 'base').map((n) => n.id),
      [1],
    );
  });
}
