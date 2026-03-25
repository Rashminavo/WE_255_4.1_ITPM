import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ragsafe_sl/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RagSafeApp());

    // Verify that the app launches (SplashScreen shows)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
