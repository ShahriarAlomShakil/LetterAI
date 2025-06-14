import 'package:shared_preferences/shared_preferences.dart';

// Define a simple enum directly in the settings service for now
enum AIProviderType {
  openai,
  gemini,
}

class SettingsService {
  static const String _themeKey = 'app_theme';
  static const String _fontSizeKey = 'font_size';
  static const String _autoSaveKey = 'auto_save';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _defaultToneKey = 'default_tone';
  static const String _apiKeyKey = 'openai_api_key';
  static const String _languageKey = 'app_language';
  static const String _aiProviderKey = 'ai_provider';
  static const String _openaiApiKeyKey = 'openai_api_key';
  static const String _geminiApiKeyKey = 'gemini_api_key';
  static const String _openaiModelKey = 'openai_model';
  static const String _geminiModelKey = 'gemini_model';
  
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
  
  /// Get AI Provider preference
  Future<AIProviderType> getAIProvider() async {
    final prefs = await SharedPreferences.getInstance();
    final providerString = prefs.getString(_aiProviderKey) ?? 'openai';
    
    switch (providerString.toLowerCase()) {
      case 'openai':
        return AIProviderType.openai;
      case 'gemini':
        return AIProviderType.gemini;
      default:
        return AIProviderType.openai;
    }
  }
  
  /// Set AI Provider preference
  Future<void> setAIProvider(AIProviderType provider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_aiProviderKey, provider.toString().split('.').last);
  }
  
  /// Get OpenAI API key specifically
  Future<String?> getOpenAIApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_openaiApiKeyKey);
  }
  
  /// Set OpenAI API key specifically
  Future<void> setOpenAIApiKey(String? apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    if (apiKey != null && apiKey.isNotEmpty) {
      await prefs.setString(_openaiApiKeyKey, apiKey);
    } else {
      await prefs.remove(_openaiApiKeyKey);
    }
  }
  
  /// Get Gemini API key
  Future<String?> getGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_geminiApiKeyKey);
  }
  
  /// Set Gemini API key
  Future<void> setGeminiApiKey(String? apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    if (apiKey != null && apiKey.isNotEmpty) {
      await prefs.setString(_geminiApiKeyKey, apiKey);
    } else {
      await prefs.remove(_geminiApiKeyKey);
    }
  }
  
  /// Get API key for specific provider
  Future<String?> getApiKeyForProvider(AIProviderType provider) async {
    print('DEBUG: Getting API key for provider: $provider');
    String? apiKey;
    
    switch (provider) {
      case AIProviderType.openai:
        apiKey = await getOpenAIApiKey() ?? await getApiKey(); // Backward compatibility
        break;
      case AIProviderType.gemini:
        apiKey = await getGeminiApiKey();
        break;
    }
    
    print('DEBUG: API key retrieved: ${apiKey != null ? 'exists (${apiKey.length} chars)' : 'null'}');
    return apiKey;
  }
  
  /// Set API key for specific provider
  Future<void> setApiKeyForProvider(AIProviderType provider, String? apiKey) async {
    switch (provider) {
      case AIProviderType.openai:
        await setOpenAIApiKey(apiKey);
        break;
      case AIProviderType.gemini:
        await setGeminiApiKey(apiKey);
        break;
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
  
  /// Get OpenAI model preference
  Future<String> getOpenAIModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_openaiModelKey) ?? 'gpt-3.5-turbo';
  }
  
  /// Set OpenAI model preference
  Future<void> setOpenAIModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_openaiModelKey, model);
  }
  
  /// Get Gemini model preference
  Future<String> getGeminiModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_geminiModelKey) ?? 'gemini-1.5-flash';
  }
  
  /// Set Gemini model preference
  Future<void> setGeminiModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_geminiModelKey, model);
  }
  
  /// Get model for specific provider
  Future<String> getModelForProvider(AIProviderType provider) async {
    switch (provider) {
      case AIProviderType.openai:
        return await getOpenAIModel();
      case AIProviderType.gemini:
        return await getGeminiModel();
    }
  }
  
  /// Set model for specific provider
  Future<void> setModelForProvider(AIProviderType provider, String model) async {
    switch (provider) {
      case AIProviderType.openai:
        await setOpenAIModel(model);
        break;
      case AIProviderType.gemini:
        await setGeminiModel(model);
        break;
    }
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
