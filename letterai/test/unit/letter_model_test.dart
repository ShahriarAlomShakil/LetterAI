// Unit tests for Letter model
import 'package:flutter_test/flutter_test.dart';
import 'package:letterai/models/letter.dart';

void main() {
  group('Letter Model Tests', () {
    test('Letter should be created with required fields', () {
      // Arrange & Act
      final letter = Letter(
        title: 'Test Letter',
        content: 'Test content',
        categoryId: 'business',
        subcategoryId: 'job_applications',
      );

      // Assert
      expect(letter.title, equals('Test Letter'));
      expect(letter.content, equals('Test content'));
      expect(letter.categoryId, equals('business'));
      expect(letter.subcategoryId, equals('job_applications'));
      expect(letter.id, isNotEmpty);
      expect(letter.createdAt, isNotNull);
      expect(letter.updatedAt, isNotNull);
      expect(letter.isTemplate, isFalse);
    });

    test('Letter should have unique IDs', () {
      // Arrange & Act
      final letter1 = Letter(
        title: 'Letter 1',
        content: 'Content 1',
        categoryId: 'business',
        subcategoryId: 'job_applications',
      );

      final letter2 = Letter(
        title: 'Letter 2',
        content: 'Content 2',
        categoryId: 'business',
        subcategoryId: 'job_applications',
      );

      // Assert
      expect(letter1.id, isNot(equals(letter2.id)));
    });

    test('copyWith should create new instance with updated fields', () {
      // Arrange
      final originalLetter = Letter(
        title: 'Original Title',
        content: 'Original content',
        categoryId: 'business',
        subcategoryId: 'job_applications',
      );

      // Act
      final updatedLetter = originalLetter.copyWith(
        title: 'Updated Title',
        content: 'Updated content',
      );

      // Assert
      expect(updatedLetter.id, equals(originalLetter.id));
      expect(updatedLetter.title, equals('Updated Title'));
      expect(updatedLetter.content, equals('Updated content'));
      expect(updatedLetter.categoryId, equals(originalLetter.categoryId));
      expect(updatedLetter.subcategoryId, equals(originalLetter.subcategoryId));
      expect(updatedLetter.createdAt, equals(originalLetter.createdAt));
      expect(updatedLetter.updatedAt, isNot(equals(originalLetter.updatedAt)));
    });

    test('Letter should handle template flag correctly', () {
      // Arrange & Act
      final templateLetter = Letter(
        title: 'Template Letter',
        content: 'Template content',
        categoryId: 'business',
        subcategoryId: 'job_applications',
        isTemplate: true,
      );

      final regularLetter = Letter(
        title: 'Regular Letter',
        content: 'Regular content',
        categoryId: 'business',
        subcategoryId: 'job_applications',
      );

      // Assert
      expect(templateLetter.isTemplate, isTrue);
      expect(regularLetter.isTemplate, isFalse);
    });

    test('Letter should handle custom dates', () {
      // Arrange
      final customDate = DateTime(2025, 1, 1);
      
      // Act
      final letter = Letter(
        title: 'Custom Date Letter',
        content: 'Content',
        categoryId: 'business',
        subcategoryId: 'job_applications',
        createdAt: customDate,
        updatedAt: customDate,
      );

      // Assert
      expect(letter.createdAt, equals(customDate));
      expect(letter.updatedAt, equals(customDate));
    });

    test('Letter should handle JSON serialization', () {
      // Arrange
      final letter = Letter(
        title: 'JSON Test Letter',
        content: 'JSON test content',
        categoryId: 'business',
        subcategoryId: 'job_applications',
      );

      // Act
      final json = letter.toJson();
      final reconstructedLetter = Letter.fromJson(json);

      // Assert
      expect(reconstructedLetter.id, equals(letter.id));
      expect(reconstructedLetter.title, equals(letter.title));
      expect(reconstructedLetter.content, equals(letter.content));
      expect(reconstructedLetter.categoryId, equals(letter.categoryId));
      expect(reconstructedLetter.subcategoryId, equals(letter.subcategoryId));
      expect(reconstructedLetter.isTemplate, equals(letter.isTemplate));
    });
  });
}
