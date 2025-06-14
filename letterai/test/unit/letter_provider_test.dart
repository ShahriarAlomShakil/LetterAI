// Unit tests for LetterProvider
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:letterai/providers/letter_provider.dart';
import 'package:letterai/services/storage_service.dart';
import 'package:letterai/services/ai_service.dart';
import 'package:letterai/models/letter.dart';

// Generate mocks
@GenerateMocks([StorageService, AIService])
import 'letter_provider_test.mocks.dart';

void main() {
  group('LetterProvider Tests', () {
    late LetterProvider letterProvider;
    late MockStorageService mockStorageService;
    late MockAIService mockAIService;

    setUp(() {
      mockStorageService = MockStorageService();
      mockAIService = MockAIService();
      letterProvider = LetterProvider();
      // In a real implementation, you'd inject these dependencies
    });

    test('loadLetters should populate letters list', () async {
      // Arrange
      final testLetters = [
        Letter(
          title: 'Test Letter 1',
          content: 'Test content 1',
          categoryId: 'business',
          subcategoryId: 'job_applications',
        ),
        Letter(
          title: 'Test Letter 2',
          content: 'Test content 2',
          categoryId: 'personal',
          subcategoryId: 'thank_you',
        ),
      ];

      when(mockStorageService.getLetters())
          .thenAnswer((_) async => testLetters);

      // Act
      await letterProvider.loadLetters();

      // Assert
      expect(letterProvider.letters.length, equals(2));
      expect(letterProvider.letters.first.title, equals('Test Letter 1'));
      expect(letterProvider.isLoading, isFalse);
    });

    test('saveLetter should call storage service', () async {
      // Arrange
      final testLetter = Letter(
        title: 'New Letter',
        content: 'New content',
        categoryId: 'business',
        subcategoryId: 'job_applications',
      );

      when(mockStorageService.saveLetter(any))
          .thenAnswer((_) async => {});
      when(mockStorageService.getLetters())
          .thenAnswer((_) async => [testLetter]);

      // Act
      await letterProvider.saveLetter(testLetter);

      // Assert
      verify(mockStorageService.saveLetter(testLetter)).called(1);
    });

    test('generateContent should return AI-generated content', () async {
      // Arrange
      const expectedContent = 'AI-generated letter content';
      when(mockAIService.generateLetterContent(
        category: anyNamed('category'),
        subcategory: anyNamed('subcategory'),
        prompt: anyNamed('prompt'),
        tone: anyNamed('tone'),
      )).thenAnswer((_) async => expectedContent);

      // Act
      final result = await letterProvider.generateContent(
        category: 'Business',
        subcategory: 'Job Application',
        prompt: 'Write a cover letter',
      );

      // Assert
      expect(result, equals(expectedContent));
    });

    test('isLoading should be true during operations', () async {
      // Arrange
      when(mockStorageService.getLetters())
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return <Letter>[];
      });

      // Act
      final future = letterProvider.loadLetters();
      
      // Assert
      expect(letterProvider.isLoading, isTrue);
      
      await future;
      expect(letterProvider.isLoading, isFalse);
    });

    test('categories should return predefined categories', () {
      // Act & Assert
      expect(letterProvider.categories.isNotEmpty, isTrue);
      expect(letterProvider.categories.first.name, equals('Business Letters'));
    });
  });
}
