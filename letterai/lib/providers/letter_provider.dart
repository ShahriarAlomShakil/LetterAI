import 'package:flutter/foundation.dart';
import '../models/letter.dart';
import '../models/letter_category.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';
import '../constants/letter_categories.dart';

class LetterProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final AIService _aiService = AIService();
  
  List<Letter> _letters = [];
  List<Letter> _templates = [];
  final List<LetterCategory> _categories = LetterCategories.categories;
  bool _isLoading = false;
  bool _isGeneratingContent = false;
  String? _error;
  
  // Current letter being edited
  Letter? _currentLetter;
  bool _hasUnsavedChanges = false;
  
  // Getters
  List<Letter> get letters => _letters;
  List<Letter> get templates => _templates;
  List<LetterCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isGeneratingContent => _isGeneratingContent;
  String? get error => _error;
  Letter? get currentLetter => _currentLetter;
  bool get hasUnsavedChanges => _hasUnsavedChanges;
  
  /// Create a new letter
  void createNewLetter(String id, String title, String content) {
    _currentLetter = Letter(
      id: id,
      title: title,
      content: content,
      categoryId: '',
      subcategoryId: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _hasUnsavedChanges = true;
    notifyListeners();
  }
  
  /// Set current letter
  void setCurrentLetter(Letter? letter) {
    _currentLetter = letter;
    _hasUnsavedChanges = false;
    notifyListeners();
  }
  
  /// Mark as having unsaved changes
  void markAsChanged() {
    _hasUnsavedChanges = true;
    notifyListeners();
  }
  
  /// Clear current letter
  void clearCurrentLetter() {
    _currentLetter = null;
    _hasUnsavedChanges = false;
    notifyListeners();
  }

  /// Load all letters from storage
  Future<void> loadLetters() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _letters = await _storageService.getLetters();
    } catch (e) {
      _error = 'Failed to load letters: $e';
      debugPrint('Error loading letters: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load all templates from storage
  Future<void> loadTemplates() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _templates = await _storageService.getTemplates();
    } catch (e) {
      _error = 'Failed to load templates: $e';
      debugPrint('Error loading templates: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Save a letter
  Future<bool> saveLetter(Letter letter) async {
    try {
      await _storageService.saveLetter(letter);
      await loadLetters(); // Refresh the list
      return true;
    } catch (e) {
      _error = 'Failed to save letter: $e';
      debugPrint('Error saving letter: $e');
      notifyListeners();
      return false;
    }
  }
  
  /// Delete a letter
  Future<bool> deleteLetter(String id) async {
    try {
      await _storageService.deleteLetter(id);
      _letters.removeWhere((letter) => letter.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete letter: $e';
      debugPrint('Error deleting letter: $e');
      notifyListeners();
      return false;
    }
  }
  
  /// Get a specific letter by ID
  Letter? getLetterById(String id) {
    try {
      return _letters.firstWhere((letter) => letter.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Get letters by category
  List<Letter> getLettersByCategory(String categoryId) {
    return _letters.where((letter) => letter.categoryId == categoryId).toList();
  }
  
  /// Get letters by subcategory
  List<Letter> getLettersBySubcategory(String subcategoryId) {
    return _letters.where((letter) => letter.subcategoryId == subcategoryId).toList();
  }
  
  /// Get recent letters (last 10)
  List<Letter> getRecentLetters({int limit = 10}) {
    final sortedLetters = List<Letter>.from(_letters);
    sortedLetters.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sortedLetters.take(limit).toList();
  }
  
  /// Generate letter content using AI
  Future<String?> generateContent({
    required String category,
    required String subcategory,
    required String prompt,
    String tone = 'professional',
  }) async {
    print('DEBUG: LetterProvider.generateContent called');
    print('Category: $category, Subcategory: $subcategory');
    
    _isGeneratingContent = true;
    _error = null;
    notifyListeners();
    
    try {
      // Check if AI is configured
      print('DEBUG: Checking AI configuration...');
      final isConfigured = await _aiService.isConfigured;
      print('DEBUG: AI configured: $isConfigured');
      
      if (!isConfigured) {
        print('DEBUG: AI not configured, returning fallback content');
        // Return fallback content if AI is not configured
        final fallback = _aiService.getFallbackContent(subcategory);
        print('DEBUG: Fallback content length: ${fallback.length}');
        return fallback;
      }
      
      print('DEBUG: Calling AI service...');
      final content = await _aiService.generateLetterContent(
        category: category,
        subcategory: subcategory,
        prompt: prompt,
        tone: tone,
      );
      print('DEBUG: AI response received, length: ${content.length}');
      return content;
    } catch (e) {
      _error = 'Failed to generate content: $e';
      print('ERROR in generateContent: $e');
      
      // Return fallback content on error
      try {
        final fallback = _aiService.getFallbackContent(subcategory);
        print('DEBUG: Returning fallback after error, length: ${fallback.length}');
        return fallback;
      } catch (fallbackError) {
        print('ERROR getting fallback content: $fallbackError');
        return 'Unable to generate content. Please check your settings and try again.';
      }
    } finally {
      _isGeneratingContent = false;
      notifyListeners();
    }
  }
  
  /// Enhance existing text with AI
  Future<List<String>> enhanceText({
    required String text,
    required String context,
  }) async {
    try {
      if (!(await _aiService.isConfigured)) {
        return [text]; // Return original text if AI not configured
      }
      
      return await _aiService.enhanceText(
        text: text,
        context: context,
      );
    } catch (e) {
      _error = 'Failed to enhance text: $e';
      debugPrint('Error enhancing text: $e');
      return [text]; // Return original text on error
    }
  }
  
  /// Generate letter outline
  Future<Map<String, String>?> generateOutline({
    required String category,
    required String subcategory,
    required String purpose,
    String tone = 'professional',
  }) async {
    try {
      if (!(await _aiService.isConfigured)) {
        return _getDefaultOutline(subcategory);
      }
      
      return await _aiService.generateLetterOutline(
        category: category,
        subcategory: subcategory,
        purpose: purpose,
        tone: tone,
      );
    } catch (e) {
      _error = 'Failed to generate outline: $e';
      debugPrint('Error generating outline: $e');
      return _getDefaultOutline(subcategory);
    }
  }
  
  /// Save a template
  Future<bool> saveTemplate(Letter template) async {
    try {
      await _storageService.saveTemplate(template);
      await loadTemplates(); // Refresh the templates list
      return true;
    } catch (e) {
      _error = 'Failed to save template: $e';
      debugPrint('Error saving template: $e');
      notifyListeners();
      return false;
    }
  }
  
  /// Delete a template
  Future<bool> deleteTemplate(String id) async {
    try {
      await _storageService.deleteTemplate(id);
      _templates.removeWhere((template) => template.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete template: $e';
      debugPrint('Error deleting template: $e');
      notifyListeners();
      return false;
    }
  }
  
  /// Search letters by text
  List<Letter> searchLetters(String query) {
    if (query.isEmpty) return _letters;
    
    final lowerQuery = query.toLowerCase();
    return _letters.where((letter) {
      return letter.title.toLowerCase().contains(lowerQuery) ||
             letter.content.toLowerCase().contains(lowerQuery);
    }).toList();
  }
  
  /// Get category by ID
  LetterCategory? getCategoryById(String id) {
    return LetterCategories.getCategoryById(id);
  }
  
  /// Get subcategory by ID
  LetterSubcategory? getSubcategoryById(String categoryId, String subcategoryId) {
    return LetterCategories.getSubcategoryById(categoryId, subcategoryId);
  }
  
  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  /// Export letters to JSON
  Future<String?> exportLetters() async {
    try {
      return await _storageService.exportLettersToJson();
    } catch (e) {
      _error = 'Failed to export letters: $e';
      debugPrint('Error exporting letters: $e');
      notifyListeners();
      return null;
    }
  }
  
  /// Import letters from JSON
  Future<bool> importLetters(String jsonString) async {
    try {
      await _storageService.importLettersFromJson(jsonString);
      await loadLetters(); // Refresh the list
      return true;
    } catch (e) {
      _error = 'Failed to import letters: $e';
      debugPrint('Error importing letters: $e');
      notifyListeners();
      return false;
    }
  }
  
  /// Get statistics
  Map<String, int> getStatistics() {
    final stats = <String, int>{};
    
    // Total letters
    stats['total_letters'] = _letters.length;
    
    // Letters by category
    for (final category in _categories) {
      final count = _letters.where((letter) => letter.categoryId == category.id).length;
      stats['category_${category.id}'] = count;
    }
    
    // Letters created this month
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    final thisMonthCount = _letters.where((letter) => 
        letter.createdAt.isAfter(thisMonth)).length;
    stats['this_month'] = thisMonthCount;
    
    return stats;
  }
  
  /// Get default outline for fallback
  Map<String, String> _getDefaultOutline(String subcategory) {
    const defaultOutlines = {
      'job_applications': {
        'Introduction': 'State the position you\'re applying for and how you learned about it.',
        'Body': 'Highlight your relevant experience, skills, and achievements. Explain why you\'re interested in the company.',
        'Conclusion': 'Express enthusiasm for the opportunity and request an interview.',
      },
      'thank_you': {
        'Introduction': 'Express gratitude and state what you\'re thanking them for.',
        'Body': 'Provide specific details about their help or kindness and its impact.',
        'Conclusion': 'Reiterate your appreciation and offer reciprocal help if appropriate.',
      },
      'resignation': {
        'Introduction': 'State your intention to resign and provide your last working day.',
        'Body': 'Express gratitude for opportunities and offer to help with transition.',
        'Conclusion': 'Maintain a positive tone and provide contact information.',
      },
    };
    
    return defaultOutlines[subcategory] ?? {
      'Introduction': 'State the purpose of your letter clearly.',
      'Body': 'Provide the main content and supporting details.',
      'Conclusion': 'Summarize key points and indicate next steps.',
    };
  }
}
