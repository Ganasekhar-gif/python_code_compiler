import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:python_cde_compiler/main.dart'; // Import your main app file
import 'package:http/http.dart' as http;
import 'dart:convert';

// Mock class for HTTP Client
class MockHttpClient extends Mock implements http.Client {}

void main() {
  testWidgets('Python code execution test', (WidgetTester tester) async {
    // Set up the mock HTTP client
    final mockHttpClient = MockHttpClient();

    // Set up the behavior for the mock client
    when(() => mockHttpClient.post(
      Uri.parse('http://127.0.0.1:5000/execute'),
      body: {'code': 'print("Hello, World!")'},
    )).thenAnswer((_) async => http.Response('Hello, World!', 200));

    // Build the app and trigger a frame with the mock client
    await tester.pumpWidget(MyApp(httpClient: mockHttpClient)); // Pass the mockHttpClient here

    // Find the input field and enter some Python code
    final codeField = find.byType(TextField);
    await tester.enterText(codeField, 'print("Hello, World!")');

    // Tap the 'Submit' button and trigger a frame
    final submitButton = find.byType(ElevatedButton);
    await tester.tap(submitButton);
    await tester.pump();

    // Verify that the output area displays the expected result
    expect(find.text('Hello, World!'), findsOneWidget);
  });
}
