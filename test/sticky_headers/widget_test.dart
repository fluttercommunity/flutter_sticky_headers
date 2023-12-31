import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

void main() {
  group('OverlapHeaders ', () {
    testWidgets('defaults to false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          // we need the SingleChildScrollView to have a scroll controller
          // available to the StickyHeader widget
          home: SingleChildScrollView(
            child: StickyHeader(
              header: Container(height: 50.0),
              content: Container(height: 200.0),
            ),
          ),
        ),
      );
      // check that the height is 250.0 (50.0 for the header + 200.0 for the content)
      expect(tester.getSize(find.byType(StickyHeader)).height, 250.0);
    });

    testWidgets('has correct size when set to true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          // we need the SingleChildScrollView to have a scroll controller
          // available to the StickyHeader widget
          home: SingleChildScrollView(
            child: StickyHeader(
              overlapHeaders: true,
              header: Container(height: 50.0),
              content: Container(height: 200.0),
            ),
          ),
        ),
      );

      // check that the height is 200.0 (200.0 for the content because the header is overlapping it)
      expect(tester.getSize(find.byType(StickyHeader)).height, 200.0);
    });
  });
  group('StickyHeaderBuilder', () {
    testWidgets('defaults to not overlapping headers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SingleChildScrollView(
            child: StickyHeaderBuilder(
              builder: (context, stuckAmount) {
                return Container(height: 50.0);
              },
              content: Container(height: 200.0),
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(StickyHeader)).height, 250.0);
    });

    testWidgets('overlaps headers when set to true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SingleChildScrollView(
            child: StickyHeaderBuilder(
              builder: (context, stuckAmount) {
                return Container(height: 50.0);
              },
              content: Container(height: 200.0),
              overlapHeaders: true,
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(StickyHeader)).height, 200.0);
    });

    testWidgets('calls builder with correct stuck amount', (tester) async {
      double? capturedStuckAmount;
      await tester.pumpWidget(
        MaterialApp(
          home: SingleChildScrollView(
            child: StickyHeaderBuilder(
              builder: (context, stuckAmount) {
                capturedStuckAmount = stuckAmount;
                return Container(height: 50.0);
              },
              content: Container(height: 200.0),
            ),
          ),
        ),
      );
      expect(capturedStuckAmount, 0.0);
    });
  });
}
