import 'package:flutter_test/flutter_test.dart';
import 'package:polyshift_web/main.dart';

void main() {
  testWidgets('PolyShift landing page smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PolyShiftWebsiteApp());
    await tester.pump();

    // Verify that the landing page renders with key text
    expect(find.text('PolyShift'), findsWidgets);
  });
}
