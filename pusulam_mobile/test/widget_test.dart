// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pusulam_mobile/main.dart';

void main() {
  testWidgets('Pusulam app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PusulamApp());

    // Verify that our app title appears.
    expect(find.text('Pusulam'), findsWidgets);
    
    // Verify that the success message appears.
    expect(find.text('Uygulama Başarıyla Çalışıyor!'), findsOneWidget);
    
    // Verify that the compass icon appears.
    expect(find.byIcon(Icons.compass_calibration), findsOneWidget);
    
    // Verify that the check circle icon appears.
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}
