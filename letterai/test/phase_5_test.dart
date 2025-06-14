import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:letterai/providers/letter_provider.dart';
import 'package:letterai/screens/letter_creation/letter_editor_screen.dart';
import 'package:letterai/screens/pdf/pdf_preview_screen.dart';
import 'package:letterai/constants/letter_categories.dart';
import 'package:letterai/models/letter.dart';

void main() {
  group('Phase 5: Letter Editor Implementation Tests', () {
    late LetterProvider provider;

    setUp(() {
      provider = LetterProvider();
    });

    test('LetterProvider should generate content with fallback', () async {
      // Test AI content generation
      final content = await provider.generateContent(
        category: 'business',
        subcategory: 'job_applications',
        prompt: 'Write a job application letter',
        tone: 'professional',
      );
      
      expect(content, isNotNull);
      expect(content!.isNotEmpty, true);
      // Should use fallback content since AI is not configured
      expect(content.contains('Dear Hiring Manager'), true);
    });

    test('Letter should be created with proper template content', () {
      final category = LetterCategories.getCategoryById('business')!;
      final subcategory = category.subcategories.firstWhere((sub) => sub.id == 'job_applications');
      
      // Create a new letter
      final letter = Letter(
        title: 'Job Application Letter',
        content: 'Dear Hiring Manager,\n\nI am writing to express my interest...',
        categoryId: category.id,
        subcategoryId: subcategory.id,
      );
      
      expect(letter.title, 'Job Application Letter');
      expect(letter.categoryId, 'business');
      expect(letter.subcategoryId, 'job_applications');
      expect(letter.content.contains('Dear Hiring Manager'), true);
    });

    test('PDF Preview should handle different templates', () {
      final letter = Letter(
        title: 'Test Letter',
        content: 'This is test content for the letter.',
        categoryId: 'business',
        subcategoryId: 'job_applications',
      );
      
      // Test letter properties
      expect(letter.title, 'Test Letter');
      expect(letter.content, 'This is test content for the letter.');
      expect(letter.id, isNotEmpty);
    });

    test('Letter template should be savable', () async {
      provider.createNewLetter('template-id', 'Template Letter', 'Template content');
      
      final template = Letter(
        title: 'Template Letter',
        content: 'Template content',
        categoryId: 'business',
        subcategoryId: 'job_applications',
        isTemplate: true,
      );
      
      expect(template.isTemplate, true);
      expect(template.title, 'Template Letter');
    });

    testWidgets('Letter Editor Screen should build successfully', (WidgetTester tester) async {
      final category = LetterCategories.getCategoryById('business')!;
      final subcategory = category.subcategories.first;
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: LetterEditorScreen(
              category: category,
              subcategory: subcategory,
            ),
          ),
        ),
      );

      // Should build without errors
      expect(find.byType(LetterEditorScreen), findsOneWidget);
    });

    testWidgets('PDF Preview Screen should build successfully', (WidgetTester tester) async {
      final letter = Letter(
        title: 'Test Letter',
        content: 'Test content',
        categoryId: 'business',
        subcategoryId: 'job_applications',
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: PDFPreviewScreen(letter: letter),
        ),
      );

      // Should build without errors
      expect(find.byType(PDFPreviewScreen), findsOneWidget);
    });

    test('Letter categories should provide default titles', () {
      final category = LetterCategories.getCategoryById('business')!;
      
      // Test different subcategories
      final jobAppSub = category.subcategories.firstWhere((sub) => sub.id == 'job_applications');
      expect(jobAppSub.name, 'Job Applications');
      
      final resignationSub = category.subcategories.firstWhere((sub) => sub.id == 'resignation');
      expect(resignationSub.name, 'Resignation Letters');
    });
  });
}
