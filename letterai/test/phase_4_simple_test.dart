import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
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

      await tester.pumpAndSettle();

      // Verify the screen loads
      expect(find.byType(LetterEditorScreen), findsOneWidget);
      
      // Verify the app bar shows the subcategory name
      expect(find.text(subcategory.name), findsOneWidget);
      
      // Verify the title field exists
      expect(find.byType(TextField), findsOneWidget);
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

    test('All categories are accessible', () {
      // Verify key categories exist
      expect(LetterCategories.getCategoryById('business'), isNotNull);
      expect(LetterCategories.getCategoryById('personal'), isNotNull);
      expect(LetterCategories.getCategoryById('academic'), isNotNull);
      
      // Verify business subcategories exist
      final businessCategory = LetterCategories.getCategoryById('business')!;
      final jobAppSubcategory = businessCategory.subcategories.firstWhere(
        (sub) => sub.id == 'job_applications',
      );
      expect(jobAppSubcategory.name, 'Job Applications');
    });

    testWidgets('Letter Provider can be initialized', (WidgetTester tester) async {
      final provider = LetterProvider();
      
      // Test basic provider functionality
      expect(provider.currentLetter, isNull);
      expect(provider.hasUnsavedChanges, false);
      
      // Create a test letter
      provider.createNewLetter('test-id', 'Test Letter', 'Test content');
      
      expect(provider.currentLetter, isNotNull);
      expect(provider.currentLetter!.title, 'Test Letter');
      expect(provider.hasUnsavedChanges, true);
    });
    
    testWidgets('Letter Provider state management works', (WidgetTester tester) async {
      final provider = LetterProvider();
      
      // Test state changes
      provider.createNewLetter('test-id', 'Test Letter', 'Test content');
      expect(provider.hasUnsavedChanges, true);
      
      // Test clearing current letter
      provider.clearCurrentLetter();
      expect(provider.currentLetter, isNull);
      expect(provider.hasUnsavedChanges, false);
    });

    testWidgets('Letter Editor Screen can handle text input', (WidgetTester tester) async {
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

      // Find and enter text in the title field
      final titleField = find.byType(TextField);
      expect(titleField, findsOneWidget);
      
      await tester.enterText(titleField, 'Test Letter Title');
      await tester.pumpAndSettle();

      // Verify the text was entered
      expect(find.text('Test Letter Title'), findsOneWidget);
    });
  });
}
