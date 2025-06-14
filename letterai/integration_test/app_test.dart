// Integration tests for LetterAI app
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:letterai/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('LetterAI Integration Tests', () {
    testWidgets('Complete letter creation flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify home screen loads
      expect(find.text('LetterAI'), findsOneWidget);
      expect(find.text('Letter Categories'), findsOneWidget);

      // Tap on new letter button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify category selection screen
      expect(find.text('Select Category'), findsOneWidget);

      // Select business category
      await tester.tap(find.text('Business Letters'));
      await tester.pumpAndSettle();

      // Verify subcategory selection screen
      expect(find.text('Job Applications'), findsOneWidget);

      // Select job application subcategory
      await tester.tap(find.text('Job Applications'));
      await tester.pumpAndSettle();

      // Verify letter editor screen loads
      expect(find.text('Job Applications'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);

      // Enter letter title
      await tester.enterText(find.byType(TextField).first, 'Test Application Letter');
      await tester.pumpAndSettle();

      // Save letter
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      // Verify save confirmation
      expect(find.text('Letter saved successfully'), findsOneWidget);
    });

    testWidgets('AI assistant functionality', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to letter editor
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Business Letters'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Job Applications'));
      await tester.pumpAndSettle();

      // Toggle AI assistant panel
      await tester.tap(find.byIcon(Icons.smart_toy));
      await tester.pumpAndSettle();

      // Verify AI panel is visible
      expect(find.text('AI Assistant'), findsOneWidget);
      expect(find.text('What would you like help with?'), findsOneWidget);
    });

    testWidgets('PDF export functionality', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Create a test letter first
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Business Letters'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Job Applications'));
      await tester.pumpAndSettle();

      // Enter content
      await tester.enterText(find.byType(TextField).first, 'Test Letter');
      await tester.pumpAndSettle();

      // Access PDF preview
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Preview PDF'));
      await tester.pumpAndSettle();

      // Verify PDF preview screen
      expect(find.text('PDF Preview'), findsOneWidget);
    });

    testWidgets('Settings and preferences', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Access settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Test various settings options
      // This would expand based on actual settings implementation
    });

    testWidgets('Data persistence test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Create a letter
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Personal Letters'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Thank You Letters'));
      await tester.pumpAndSettle();

      // Enter content and save
      await tester.enterText(find.byType(TextField).first, 'Persistent Test Letter');
      await tester.pumpAndSettle();
      
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      // Navigate back to home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify letter appears in recent letters
      expect(find.text('Persistent Test Letter'), findsOneWidget);
    });
  });
}
