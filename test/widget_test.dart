// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_remidi/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences initial values
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const SpaceNewsApp());

    // Verify that the splash screen shows the title.
    expect(find.text('SpaceNews Core'), findsOneWidget);
    expect(find.text('Advanced News Portal'), findsOneWidget);

    // Let the 3-second splash screen timer expire and trigger navigation
    await tester.pump(const Duration(seconds: 3));
    // Settle navigation frame transitions
    await tester.pump(const Duration(milliseconds: 500));
  });
}
