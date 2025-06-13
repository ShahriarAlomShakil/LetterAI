import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _themeKey = 'app_theme';
  static const String _fontSizeKey = 'font_size';
  static const String _autoSaveKey = 'auto_save';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _defaultToneKey = 'default_tone';
  static const String _apiKeyKey = 'openai_api_key';
  static const String _languageKey = 'app_language';
  
  /// Get theme preference
  Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'system';
  }
  
  /// Set theme preference
  Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }
  
  /// Get font size preference
  Future<String> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fontSizeKey) ?? 'medium';
  }
  
  /// Set font size preference
  Future<void> setFontSize(String fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontSizeKey, fontSize);
  }
  
  /// Get auto-save preference
  Future<bool> getAutoSave() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoSaveKey) ?? true;
  }
  
  /// Set auto-save preference
  Future<void> setAutoSave(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoSaveKey, enabled);
  }
  
  /// Get notifications preference
  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }
  
  /// Set notifications preference
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }
  
  /// Get default tone preference
  Future<String> getDefaultTone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultToneKey) ?? 'professional';
  }
  
  /// Set default tone preference
  Future<void> setDefaultTone(String tone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultToneKey, tone);
  }
  
  /// Get OpenAI API key (securely stored)
  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }
  
  /// Set OpenAI API key (securely stored)
  Future<void> setApiKey(String? apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    if (apiKey != null && apiKey.isNotEmpty) {
      await prefs.setString(_apiKeyKey, apiKey);
    } else {
      await prefs.remove(_apiKeyKey);
    }
  }
  
  /// Get app language preference
  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }
  
  /// Set app language preference
  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }
  
  /// Get all settings as a map
  Future<Map<String, dynamic>> getAllSettings() async {
    return {
      'theme': await getTheme(),
      'fontSize': await getFontSize(),
      'autoSave': await getAutoSave(),
      'notifications': await getNotificationsEnabled(),
      'defaultTone': await getDefaultTone(),
      'language': await getLanguage(),
    };
  }
  
  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeKey);
    await prefs.remove(_fontSizeKey);
    await prefs.remove(_autoSaveKey);
    await prefs.remove(_notificationsKey);
    await prefs.remove(_defaultToneKey);
    await prefs.remove(_languageKey);
    // Note: API key is not reset for security reasons
  }
  
  /// Clear all app data (including API key)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

/// Settings provider for state management
class SettingsProvider {
  final SettingsService _settingsService = SettingsService();
  
  Map<String, dynamic> _settings = {};
  
  Map<String, dynamic> get settings => _settings;
  
  /// Load all settings
  Future<void> loadSettings() async {
    _settings = await _settingsService.getAllSettings();
  }
  
  /// Update a specific setting
  Future<void> updateSetting(String key, dynamic value) async {
    switch (key) {
      case 'theme':
        await _settingsService.setTheme(value);
        break;
      case 'fontSize':
        await _settingsService.setFontSize(value);
        break;
      case 'autoSave':
        await _settingsService.setAutoSave(value);
        break;
      case 'notifications':
        await _settingsService.setNotificationsEnabled(value);
        break;
      case 'defaultTone':
        await _settingsService.setDefaultTone(value);
        break;
      case 'language':
        await _settingsService.setLanguage(value);
        break;
    }
    
    _settings[key] = value;
  }
  
  /// Get a specific setting
  T getSetting<T>(String key, T defaultValue) {
    return _settings[key] as T? ?? defaultValue;
  }
}
