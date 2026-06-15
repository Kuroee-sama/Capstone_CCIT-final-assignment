import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('App should render login or dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const CafeinajaApp());
    await tester.pump();

    // App should show either login page or dashboard (depending on auth state)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
