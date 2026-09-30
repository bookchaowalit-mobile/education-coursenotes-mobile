import 'package:coursenotes/main.dart';
import 'package:coursenotes/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app shell shows notes and about tab', (tester) async {
    await tester.pumpWidget(const CoursenotesApp());
    expect(find.text('Coursenotes'), findsWidgets);
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.text('Features'), findsOneWidget);
  });

  testWidgets('add, search and delete a note', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
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
}
