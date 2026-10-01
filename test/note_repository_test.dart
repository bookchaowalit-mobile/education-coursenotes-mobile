import 'dart:convert';

import 'package:coursenotes/data/list_repository.dart';
import 'package:coursenotes/data/note_repository.dart';
import 'package:coursenotes/logic/notes.dart';
import 'package:coursenotes/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final note = Note(
    id: 3,
    course: 'CS101',
    topic: 'Graphs',
    body: 'BFS uses a queue',
    createdAt: DateTime.utc(2026, 1, 2, 3, 4),
  );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('round-trips notes through shared_preferences', () async {
    await deviceNoteRepository.save([note]);
    final loaded = await deviceNoteRepository.load();
    expect(loaded, hasLength(1));
    expect(loaded.single.toJson(), note.toJson());
  });

  test('empty storage loads an empty list', () async {
    expect(await deviceNoteRepository.load(), isEmpty);
  });

  test('skips malformed records and rejects non-list payloads', () async {
    SharedPreferences.setMockInitialValues({
      'coursenotes_notes_v1': jsonEncode([
        note.toJson(),
        {'id': 'x'},
        42,
      ]),
    });
    expect(await deviceNoteRepository.load(), hasLength(1));

    SharedPreferences.setMockInitialValues({'coursenotes_notes_v1': '{}'});
    expect(deviceNoteRepository.load(), throwsFormatException);
  });

  testWidgets('home screen restores saved notes and saves new ones',
      (tester) async {
    final repo = InMemoryListRepository<Note>([note]);
    await tester.pumpWidget(MaterialApp(home: HomeScreen(repository: repo)));
    await tester.pumpAndSettle();
    expect(find.text('CS101 · Graphs'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete note'));
    await tester.pumpAndSettle();
    expect(await repo.load(), isEmpty);
  });

  testWidgets('shows an error when saved notes cannot be read', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(repository: _FailingRepository())),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('storage-error')), findsOneWidget);
  });
}

class _FailingRepository implements ListRepository<Note> {
  @override
  Future<List<Note>> load() async => throw const FormatException('bad');

  @override
  Future<void> save(List<Note> items) async => throw StateError('full');
}
