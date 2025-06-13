import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/letter.dart';

class StorageService {
  static const String _lettersKey = 'user_letters';
  static const String _templatesKey = 'user_templates';
  static const String _settingsKey = 'app_settings';
  
  /// Get all user letters from storage
  Future<List<Letter>> getLetters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lettersJson = prefs.getStringList(_lettersKey) ?? [];
      
      return lettersJson
          .map((json) => Letter.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      throw StorageException('Failed to load letters: $e');
    }
  }
  
  /// Save a letter to storage
  Future<void> saveLetter(Letter letter) async {
    try {
      final letters = await getLetters();
      final existingIndex = letters.indexWhere((l) => l.id == letter.id);
      
      if (existingIndex >= 0) {
        letters[existingIndex] = letter;
      } else {
        letters.add(letter);
      }
      
      await _saveLetters(letters);
    } catch (e) {
      throw StorageException('Failed to save letter: $e');
    }
  }
  
  /// Delete a letter from storage
  Future<void> deleteLetter(String id) async {
    try {
      final letters = await getLetters();
      letters.removeWhere((letter) => letter.id == id);
      await _saveLetters(letters);
    } catch (e) {
      throw StorageException('Failed to delete letter: $e');
    }
  }
  
  /// Get a specific letter by ID
  Future<Letter?> getLetter(String id) async {
    try {
      final letters = await getLetters();
      return letters.where((letter) => letter.id == id).firstOrNull;
    } catch (e) {
      throw StorageException('Failed to get letter: $e');
    }
  }
  
  /// Get letters by category
  Future<List<Letter>> getLettersByCategory(String categoryId) async {
    try {
      final letters = await getLetters();
      return letters.where((letter) => letter.categoryId == categoryId).toList();
    } catch (e) {
      throw StorageException('Failed to get letters by category: $e');
    }
  }
  
  /// Get letters by subcategory
  Future<List<Letter>> getLettersBySubcategory(String subcategoryId) async {
    try {
      final letters = await getLetters();
      return letters.where((letter) => letter.subcategoryId == subcategoryId).toList();
    } catch (e) {
      throw StorageException('Failed to get letters by subcategory: $e');
    }
  }
  
  /// Get all template letters
  Future<List<Letter>> getTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = prefs.getStringList(_templatesKey) ?? [];
      
      return templatesJson
          .map((json) => Letter.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      throw StorageException('Failed to load templates: $e');
    }
  }
  
  /// Save a template letter
  Future<void> saveTemplate(Letter template) async {
    try {
      final templates = await getTemplates();
      final existingIndex = templates.indexWhere((t) => t.id == template.id);
      
      if (existingIndex >= 0) {
        templates[existingIndex] = template;
      } else {
        templates.add(template);
      }
      
      await _saveTemplates(templates);
    } catch (e) {
      throw StorageException('Failed to save template: $e');
    }
  }
  
  /// Delete a template
  Future<void> deleteTemplate(String id) async {
    try {
      final templates = await getTemplates();
      templates.removeWhere((template) => template.id == id);
      await _saveTemplates(templates);
    } catch (e) {
      throw StorageException('Failed to delete template: $e');
    }
  }
  
  /// Save app settings
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(settings));
    } catch (e) {
      throw StorageException('Failed to save settings: $e');
    }
  }
  
  /// Get app settings
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        return jsonDecode(settingsJson);
      }
      
      // Return default settings
      return {
        'theme': 'system',
        'fontSize': 'medium',
        'autoSave': true,
        'notifications': true,
      };
    } catch (e) {
      throw StorageException('Failed to load settings: $e');
    }
  }
  
  /// Clear all data (for logout or reset)
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lettersKey);
      await prefs.remove(_templatesKey);
      await prefs.remove(_settingsKey);
    } catch (e) {
      throw StorageException('Failed to clear data: $e');
    }
  }
  
  /// Export letters to JSON string
  Future<String> exportLettersToJson() async {
    try {
      final letters = await getLetters();
      final lettersJson = letters.map((letter) => letter.toJson()).toList();
      return jsonEncode(lettersJson);
    } catch (e) {
      throw StorageException('Failed to export letters: $e');
    }
  }
  
  /// Import letters from JSON string
  Future<void> importLettersFromJson(String jsonString) async {
    try {
      final List<dynamic> lettersJson = jsonDecode(jsonString);
      final letters = lettersJson
          .map((json) => Letter.fromJson(json))
          .toList();
      
      await _saveLetters(letters);
    } catch (e) {
      throw StorageException('Failed to import letters: $e');
    }
  }
  
  /// Internal method to save letters list
  Future<void> _saveLetters(List<Letter> letters) async {
    final prefs = await SharedPreferences.getInstance();
    final lettersJson = letters
        .map((letter) => jsonEncode(letter.toJson()))
        .toList();
    await prefs.setStringList(_lettersKey, lettersJson);
  }
  
  /// Internal method to save templates list
  Future<void> _saveTemplates(List<Letter> templates) async {
    final prefs = await SharedPreferences.getInstance();
    final templatesJson = templates
        .map((template) => jsonEncode(template.toJson()))
        .toList();
    await prefs.setStringList(_templatesKey, templatesJson);
  }
}

/// Custom exception for storage operations
class StorageException implements Exception {
  final String message;
  
  const StorageException(this.message);
  
  @override
  String toString() => 'StorageException: $message';
}

/// Extension for List.firstOrNull (if not available in current Dart version)
extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
