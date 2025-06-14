import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:letterai/main.dart';
import 'package:letterai/providers/letter_provider.dart';
import 'package:letterai/screens/letter_creation/letter_editor_screen.dart';
import 'package:letterai/constants/letter_categories.dart';

void main() {
  group('Phase 4 Implementation Tests', () {
    testWidgets('Letter Editor Screen should initialize correctly', (WidgetTester tester) async {
      final category = LetterCategories.getCategoryById('business')!;
      final subcategory = category.subcategories.first;
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => LetterProvider(),
            child: LetterEditorScreen(
              category: category,
              subcategory: subcategory,
            ),
          ),
        ),
      );

      // Verify the screen loads
      expect(find.byType(LetterEditorScreen), findsOneWidget);
      
      // Verify the app bar shows the subcategory name
      expect(find.text(subcategory.name), findsOneWidget);
      
      // Verify the title field exists
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Home screen should display correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LetterProvider()),
          ],
          child: const LetterAIApp(),
        ),
      );

      // Wait for the app to load
      await tester.pumpAndSettle();

      // Verify we're on the home screen
      expect(find.text('LetterAI'), findsOneWidget);

      // Verify the New Letter FAB exists
      expect(find.text('New Letter'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('Letter Editor Screen initializes and displays correctly', (WidgetTester tester) async {
      final category = LetterCategories.getCategoryById('business')!;
      final subcategory = category.subcategories.first;
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => LetterProvider(),
            child: LetterEditorScreen(
              category: category,
              subcategory: subcategory,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the screen loads with correct title
      expect(find.text(subcategory.name), findsOneWidget);
      
      // Verify the AI assistant FAB exists
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    test('Letter categories are properly defined', () {
      final category = LetterCategories.getCategoryById('business')!;
      
      // Test that business category has the expected subcategories
      expect(category.subcategories.length, greaterThan(3));
      
      final jobAppSubcategory = category.subcategories.firstWhere(
        (sub) => sub.id == 'job_applications',
      );
      expect(jobAppSubcategory.name, 'Job Applications');
      expect(jobAppSubcategory.description, 'Cover letters and job application letters');
    });

    testWidgets('Letter title can be edited', (WidgetTester tester) async {
      final category = LetterCategories.getCategoryById('personal')!;
      final subcategory = category.subcategories.first;
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => LetterProvider(),
            child: LetterEditorScreen(
              category: category,
              subcategory: subcategory,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the title field (there should be one TextField for title)
      final titleField = find.byType(TextField);
      expect(titleField, findsAtLeastNWidgets(1));
      
      // Enter some text in the title field
      await tester.enterText(titleField.first, 'Test Letter Title');
      await tester.pumpAndSettle();

      // Verify that the text was entered
      expect(find.text('Test Letter Title'), findsOneWidget);
    });
  });
}
