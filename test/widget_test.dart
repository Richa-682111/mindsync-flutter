import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindsync/widgets/design/primary_button.dart';
import 'package:mindsync/widgets/design/progress_ring.dart';
import 'package:mindsync/widgets/design/section_header.dart';

void main() {
  testWidgets('PrimaryButton renders text and triggers callback', (WidgetTester tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            text: 'Continue',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Continue'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('SectionHeader shows title subtitle and trailing widget', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SectionHeader(
            title: 'Mood Trends',
            subtitle: 'Last 7 days',
            trailing: Icon(Icons.chevron_right),
          ),
        ),
      ),
    );

    expect(find.text('Mood Trends'), findsOneWidget);
    expect(find.text('Last 7 days'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('ProgressRing renders two progress indicators and center content',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProgressRing(
            progress: 0.6,
            progressColor: Colors.blue,
            centerWidget: Text('60%'),
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
    expect(find.text('60%'), findsOneWidget);
  });
}
