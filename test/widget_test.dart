// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rutapuma/main.dart';

void main() {
  testWidgets('App loads and shows login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RutaPumaApp());

    // Verify that the login screen loads with RUTAPUMA text
    expect(find.text('RUTAPUMA'), findsOneWidget);

    // Verify that role selection buttons are present
    expect(find.text('USUARIO'), findsOneWidget);
    expect(find.text('CONDUCTOR'), findsOneWidget);
  });
}
