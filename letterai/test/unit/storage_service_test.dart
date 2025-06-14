// Unit tests for StorageService
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:letterai/services/storage_service.dart';
import 'package:letterai/models/letter.dart';

void main() {
  group('StorageService Tests', () {
    late StorageService storageService;

    setUp(() {
      storageService = StorageService();
      // Set up mock shared preferences
      SharedPreferences.setMockInitialValues({});
    });

    test('getLetters should return empty list when no letters stored', () async {
      // Act
      final letters = await storageService.getLetters();

      // Assert
      expect(letters, isEmpty);
    });

    test('saveLetter should store letter in shared preferences', () async {
      // Arrange
      final testLetter = Letter(
        title: 'Test Letter',
        content: 'Test content',
        categoryId: 'business',
        subcategoryId: 'job_applications',
      );

      // Act
      await storageService.saveLetter(testLetter);
      final letters = await storageService.getLetters();

      // Assert
      expect(letters.length, equals(1));
      expect(letters.first.title, equals('Test Letter'));
      expect(letters.first.content, equals('Test content'));
    });

    test('deleteLetter should remove letter from storage', () async {
      // Arrange
      final testLetter = Letter(
        title: 'Test Letter',
        content: 'Test content',
        categoryId: 'business',
        subcategoryId: 'job_applications',
      );

      await storageService.saveLetter(testLetter);
      
      // Act
      await storageService.deleteLetter(testLetter.id);
      final letters = await storageService.getLetters();

      // Assert
      expect(letters, isEmpty);
    });

    test('saveLetter should update existing letter', () async {
      // Arrange
      final originalLetter = Letter(
        title: 'Original Title',
        content: 'Original content',
        categoryId: 'business',
        subcategoryId: 'job_applications',
      );

      await storageService.saveLetter(originalLetter);

      final updatedLetter = originalLetter.copyWith(
        title: 'Updated Title',
        content: 'Updated content',
      );

      // Act
      await storageService.saveLetter(updatedLetter);
      final letters = await storageService.getLetters();

      // Assert
      expect(letters.length, equals(1));
      expect(letters.first.title, equals('Updated Title'));
      expect(letters.first.content, equals('Updated content'));
    });

    test('multiple letters should be stored and retrieved correctly', () async {
      // Arrange
      final letters = [
        Letter(
          title: 'Letter 1',
          content: 'Content 1',
          categoryId: 'business',
          subcategoryId: 'job_applications',
        ),
        Letter(
          title: 'Letter 2',
          content: 'Content 2',
          categoryId: 'personal',
          subcategoryId: 'thank_you',
        ),
        Letter(
          title: 'Letter 3',
          content: 'Content 3',
          categoryId: 'business',
          subcategoryId: 'resignation',
        ),
      ];

      // Act
      for (final letter in letters) {
        await storageService.saveLetter(letter);
      }
      final storedLetters = await storageService.getLetters();

      // Assert
      expect(storedLetters.length, equals(3));
      expect(storedLetters.map((l) => l.title).toList(),
          containsAll(['Letter 1', 'Letter 2', 'Letter 3']));
    });
  });
}
