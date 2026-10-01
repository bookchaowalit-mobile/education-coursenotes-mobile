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

  group('edge cases (pass 3)', () {
    Note mk(int id, String topic, {String body = 'b', String course = 'C'}) =>
        Note(
          id: id,
          course: course,
          topic: topic,
          body: body,
          createdAt: DateTime(2026, 1, 1),
        );

    test('body limit counts visible characters', () {
      String? check(String body) =>
          validateNote(course: 'C', topic: 'T', body: body);
      expect(check('😀' * noteBodyMax), isNull);
      expect(check('😀' * (noteBodyMax + 1)), contains('at most'));
      expect(check('  ${'a' * noteBodyMax}  '), isNull);
      expect(check(' \n\t '), 'Note text is required');
    });

    test('whitespace-only query and tabs/newlines between terms', () {
      final notes = [mk(1, 'Graphs', body: 'BFS uses a queue')];
      expect(searchNotes(notes, query: '   '), hasLength(1));
      expect(searchNotes(notes, query: '\tbfs\n  QUEUE '), hasLength(1));
      expect(searchNotes(notes, query: 'bfs stack'), isEmpty);
    });

    test('Thai and emoji text is searchable', () {
      final notes = [mk(1, 'กราฟ', body: 'ค้นหาแบบกว้าง 🌳')];
      expect(searchNotes(notes, query: 'แบบกว้าง'), hasLength(1));
      expect(searchNotes(notes, query: '🌳'), hasLength(1));
      expect(searchNotes(notes, topic: 'กราฟ'), hasLength(1));
    });

    test('same timestamp falls back to newest id first', () {
      final result = searchNotes([mk(1, 'A'), mk(3, 'A'), mk(2, 'A')]);
      expect(result.map((n) => n.id), [3, 2, 1]);
    });

    test('empty collections', () {
      expect(topicsOf(const []), isEmpty);
      expect(searchNotes(const [], query: 'x'), isEmpty);
      expect(hasTopic(const [], 'x'), isFalse);
    });

    test('hasTopic ignores letter case', () {
      final notes = [mk(2, 'graphs')];
      expect(hasTopic(notes, 'Graphs'), isTrue);
      expect(hasTopic(notes, 'Trees'), isFalse);
    });

    test('JSON round trip keeps unicode and trims fields', () {
      final n = mk(7, '  กราฟ  ', body: '  😀 note ');
      final back = Note.fromJson(n.toJson());
      expect(back.topic, 'กราฟ');
      expect(back.body, '😀 note');
      expect(back.createdAt, n.createdAt);
    });
  });
}
