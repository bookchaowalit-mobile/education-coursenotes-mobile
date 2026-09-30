import 'package:coursenotes/main.dart';
import 'package:coursenotes/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('app shell shows notes and about tab', (tester) async {
    await tester.pumpWidget(const CoursenotesApp());
    await tester.pumpAndSettle();
    expect(find.text('Coursenotes'), findsWidgets);
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.text('Features'), findsOneWidget);
  });

  testWidgets('add, search and delete a note', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
    expect(find.textContaining('No notes yet'), findsOneWidget);

    await tester.tap(find.byKey(const Key('add-note')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-note')));
    await tester.pump();
    expect(find.text('Course is required'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('course-field')), 'CS101');
    await tester.enterText(find.byKey(const Key('topic-field')), 'Graphs');
    await tester.enterText(
        find.byKey(const Key('body-field')), 'BFS uses a queue');
    await tester.tap(find.byKey(const Key('save-note')));
    await tester.pumpAndSettle();
    expect(find.text('CS101 · Graphs'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('search')), 'stack');
    await tester.pump();
    expect(find.text('No notes match.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('search')), 'queue');
    await tester.pump();
    expect(find.text('CS101 · Graphs'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete note'));
    await tester.pump();
    expect(find.textContaining('No notes yet'), findsOneWidget);
  });

  Future<void> addNote(
    WidgetTester tester,
    String course,
    String topic,
    String body,
  ) async {
    await tester.tap(find.byKey(const Key('add-note')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('course-field')), course);
    await tester.enterText(find.byKey(const Key('topic-field')), topic);
    await tester.enterText(find.byKey(const Key('body-field')), body);
    await tester.tap(find.byKey(const Key('save-note')));
    await tester.pumpAndSettle();
  }

  Widget home({double textScale = 1}) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: HomeScreen(clock: () => DateTime(2026, 10, 1)),
        ),
      );

  testWidgets('undo restores a deleted note', (tester) async {
    await tester.pumpWidget(home());
    await tester.pumpAndSettle();
    await addNote(tester, 'CS101', 'Graphs', 'BFS uses a queue');
    await tester.tap(find.byTooltip('Delete note'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No notes yet'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('CS101 · Graphs'), findsOneWidget);
  });

  testWidgets('topic filter survives deleting the note that named it', (
    tester,
  ) async {
    await tester.pumpWidget(home());
    await tester.pumpAndSettle();
    await addNote(tester, 'CS101', 'Graphs', 'first');
    await addNote(tester, 'CS102', 'graphs', 'second');
    await addNote(tester, 'CS103', 'Trees', 'third');
    await tester.tap(find.widgetWithText(FilterChip, 'Graphs'));
    await tester.pump();
    expect(find.text('CS103 · Trees'), findsNothing);

    // Delete "CS101 · Graphs" (the spelling on the chip).
    final tile = find.ancestor(
      of: find.text('CS101 · Graphs'),
      matching: find.byType(ListTile),
    );
    await tester.tap(
      find.descendant(of: tile, matching: find.byTooltip('Delete note')),
    );
    await tester.pumpAndSettle();
    expect(find.text('CS102 · graphs'), findsOneWidget);
    expect(find.text('CS103 · Trees'), findsNothing);
    final chip = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'graphs'),
    );
    expect(chip.selected, isTrue);
  });

  testWidgets('cancel leaves the list unchanged', (tester) async {
    await tester.pumpWidget(home());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-note')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('course-field')), 'X');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No notes yet'), findsOneWidget);
  });

  testWidgets('meets tap-target, label and contrast guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(home());
    await tester.pumpAndSettle();
    await addNote(tester, 'CS101', 'Graphs', 'BFS uses a queue');
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });

  testWidgets('lays out at 200% text scale without overflow', (tester) async {
    await tester.pumpWidget(home(textScale: 2));
    await tester.pumpAndSettle();
    await addNote(tester, 'CS101', 'Graphs', 'BFS uses a queue');
    expect(tester.takeException(), isNull);
  });
}
