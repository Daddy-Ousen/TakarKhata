// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:khatabook/main.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App starts correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: KhataBookApp()));

    // Verify the loading screen appears.
    expect(find.text('TakarKhata'), findsOneWidget);
  });
}
