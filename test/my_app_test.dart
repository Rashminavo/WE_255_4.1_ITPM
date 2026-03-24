import 'package:flutter_test/flutter_test.dart';
import 'package:awareness_education_hub/main.dart';

void main() {
  testWidgets('HubHomeScreen displays header and all 4 cards',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AwarenessHubApp());

    expect(find.text('AWARENESS &\nEDUCATION HUB'), findsOneWidget);
    expect(find.text('Resources'), findsOneWidget);
    expect(find.text('Interactive Quiz'), findsOneWidget);
    expect(find.text('Consequences\nFlowchart'), findsOneWidget);
    expect(find.text('Progress &\nBadges'), findsOneWidget);
  });
}