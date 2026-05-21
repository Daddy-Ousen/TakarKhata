// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:khatabook/main.dart';

void main() {
  testWidgets('App starts correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KhataBookApp());

    // Verify the loading screen appears.
    expect(find.text('KhataBook'), findsOneWidget);
  });
}
