import 'package:flutter_test/flutter_test.dart';
import 'package:flash_idea/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FlashIdeaApp());

    // Verify that the app loads
    expect(find.text('灵感闪记'), findsOneWidget);
  });
}
