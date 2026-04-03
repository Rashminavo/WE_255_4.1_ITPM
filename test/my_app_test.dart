import 'package:flutter_test/flutter_test.dart';
import 'package:ragsafe_sl/main.dart';

void main() {
  testWidgets('MyApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RagaSafeApp());

    // Verify that the app title is displayed
    expect(find.text('RagSafe SL'), findsOneWidget);
  });
}
