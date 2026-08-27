import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_ai/shared/widgets/risk_chip.dart';

void main() {
  testWidgets('RiskChip displays correct label and icon for low risk', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RiskChip(level: RiskLevel.low),
        ),
      ),
    );

    expect(find.text('Low Risk'), findsOneWidget);
    expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
  });

  testWidgets('RiskChip displays correct label and icon for critical risk', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RiskChip(level: RiskLevel.critical),
        ),
      ),
    );

    expect(find.text('Critical'), findsOneWidget);
    expect(find.byIcon(Icons.emergency_outlined), findsOneWidget);
  });
}
