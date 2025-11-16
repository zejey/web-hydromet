// This is a basic Flutter widget test for the Admin Dashboard.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_admin_dashboard/main.dart';

void main() {
  testWidgets('Admin Dashboard app launches and shows login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AdminDashboardApp());

    // Verify that the login screen is displayed initially.
    expect(find.text('CDRRMO Admin Login'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Login form validation works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AdminDashboardApp());

    // Try to login without entering credentials
    await tester.tap(find.text('Login'));
    await tester.pump();

    // Verify that validation messages appear
    expect(find.text('Please enter username'), findsOneWidget);
    expect(find.text('Please enter password'), findsOneWidget);
  });
}
