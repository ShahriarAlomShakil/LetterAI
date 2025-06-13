import 'package:flutter_test/flutter_test.dart';
import 'package:letterai/models/letter.dart';
import 'package:letterai/constants/letter_categories.dart';
import 'package:letterai/services/ai_service.dart';

void main() {
  group('Phase 2 Implementation Tests', () {
    test('Letter Categories should be properly defined', () {
      const categories = LetterCategories.categories;
      
      expect(categories.isNotEmpty, true);
      expect(categories.length, greaterThan(5));
      
      // Check business category exists
      final businessCategory = LetterCategories.getCategoryById('business');
      expect(businessCategory, isNotNull);
      expect(businessCategory!.name, 'Business Letters');
      expect(businessCategory.subcategories.isNotEmpty, true);
      
      // Check job applications subcategory exists
      final jobAppSubcategory = LetterCategories.getSubcategoryById('business', 'job_applications');
      expect(jobAppSubcategory, isNotNull);
      expect(jobAppSubcategory!.name, 'Job Applications');
    });
    
    test('Letter model should serialize to/from JSON correctly', () {
      final letter = Letter(
        title: 'Test Letter',
        content: 'This is a test letter content.',
        categoryId: 'business',
        subcategoryId: 'job_applications',
      );
      
      // Test toJson
      final json = letter.toJson();
      expect(json['title'], 'Test Letter');
      expect(json['content'], 'This is a test letter content.');
      expect(json['categoryId'], 'business');
      expect(json['subcategoryId'], 'job_applications');
      expect(json['id'], isNotNull);
      expect(json['createdAt'], isNotNull);
      expect(json['updatedAt'], isNotNull);
      expect(json['isTemplate'], false);
      
      // Test fromJson
      final deserializedLetter = Letter.fromJson(json);
      expect(deserializedLetter.id, letter.id);
      expect(deserializedLetter.title, letter.title);
      expect(deserializedLetter.content, letter.content);
      expect(deserializedLetter.categoryId, letter.categoryId);
      expect(deserializedLetter.subcategoryId, letter.subcategoryId);
      expect(deserializedLetter.isTemplate, letter.isTemplate);
    });
    
    test('Letter copyWith should work correctly', () {
      final originalLetter = Letter(
        title: 'Original Title',
        content: 'Original Content',
        categoryId: 'business',
        subcategoryId: 'job_applications',
      );
      
      final updatedLetter = originalLetter.copyWith(
        title: 'Updated Title',
        content: 'Updated Content',
      );
      
      expect(updatedLetter.id, originalLetter.id); // ID should remain same
      expect(updatedLetter.categoryId, originalLetter.categoryId); // Category should remain same
      expect(updatedLetter.subcategoryId, originalLetter.subcategoryId); // Subcategory should remain same
      expect(updatedLetter.title, 'Updated Title');
      expect(updatedLetter.content, 'Updated Content');
      expect(updatedLetter.updatedAt.isAfter(originalLetter.updatedAt), true);
    });
    
    test('AIService should provide fallback content', () {
      final aiService = AIService();
      
      // Test isConfigured (should be false with default API key)
      expect(aiService.isConfigured, false);
      
      // Test fallback content
      final fallbackContent = aiService.getFallbackContent('job_applications');
      expect(fallbackContent.isNotEmpty, true);
      expect(fallbackContent.contains('[Position Title]'), true);
      expect(fallbackContent.contains('[Company Name]'), true);
      expect(fallbackContent.contains('[Your Name]'), true);
      
      // Test other subcategories
      final thankYouContent = aiService.getFallbackContent('thank_you');
      expect(thankYouContent.isNotEmpty, true);
      expect(thankYouContent.contains('[Recipient Name]'), true);
      
      final resignationContent = aiService.getFallbackContent('resignation');
      expect(resignationContent.isNotEmpty, true);
      expect(resignationContent.contains('[Manager\'s Name]'), true);
      
      // Test unknown subcategory returns default template
      final unknownContent = aiService.getFallbackContent('unknown_category');
      expect(unknownContent.isNotEmpty, true);
      expect(unknownContent.contains('[Recipient]'), true);
    });
    
    test('LetterCategories utility methods should work', () {
      // Test getCategoryById
      final businessCategory = LetterCategories.getCategoryById('business');
      expect(businessCategory, isNotNull);
      expect(businessCategory!.id, 'business');
      
      final nonExistentCategory = LetterCategories.getCategoryById('non_existent');
      expect(nonExistentCategory, isNull);
      
      // Test getSubcategoryById
      final jobAppSubcategory = LetterCategories.getSubcategoryById('business', 'job_applications');
      expect(jobAppSubcategory, isNotNull);
      expect(jobAppSubcategory!.id, 'job_applications');
      expect(jobAppSubcategory.categoryId, 'business');
      
      final nonExistentSubcategory = LetterCategories.getSubcategoryById('business', 'non_existent');
      expect(nonExistentSubcategory, isNull);
      
      // Test getAllSubcategories
      final allSubcategories = LetterCategories.getAllSubcategories();
      expect(allSubcategories.length, greaterThan(10));
      
      // Verify all subcategories have valid category references
      for (final subcategory in allSubcategories) {
        final parentCategory = LetterCategories.getCategoryById(subcategory.categoryId);
        expect(parentCategory, isNotNull);
        expect(parentCategory!.subcategories.any((sub) => sub.id == subcategory.id), true);
      }
    });
    
    test('All letter categories should have valid structure', () {
      const categories = LetterCategories.categories;
      
      for (final category in categories) {
        // Each category should have valid properties
        expect(category.id.isNotEmpty, true);
        expect(category.name.isNotEmpty, true);
        expect(category.icon.isNotEmpty, true);
        expect(category.subcategories.isNotEmpty, true);
        
        // Each subcategory should reference the correct parent category
        for (final subcategory in category.subcategories) {
          expect(subcategory.id.isNotEmpty, true);
          expect(subcategory.name.isNotEmpty, true);
          expect(subcategory.description.isNotEmpty, true);
          expect(subcategory.categoryId, category.id);
        }
      }
    });
    
    test('Letter creation with various parameters should work', () {
      // Test with minimal parameters
      final minimalLetter = Letter(
        title: 'Minimal Letter',
        content: 'Minimal content',
        categoryId: 'personal',
        subcategoryId: 'thank_you',
      );
      
      expect(minimalLetter.id.isNotEmpty, true);
      expect(minimalLetter.isTemplate, false);
      expect(minimalLetter.createdAt, isNotNull);
      expect(minimalLetter.updatedAt, isNotNull);
      
      // Test with all parameters
      final now = DateTime.now();
      final fullLetter = Letter(
        id: 'custom-id',
        title: 'Full Letter',
        content: 'Full content',
        categoryId: 'business',
        subcategoryId: 'job_applications',
        createdAt: now,
        updatedAt: now,
        isTemplate: true,
      );
      
      expect(fullLetter.id, 'custom-id');
      expect(fullLetter.isTemplate, true);
      expect(fullLetter.createdAt, now);
      expect(fullLetter.updatedAt, now);
    });
  });
}
