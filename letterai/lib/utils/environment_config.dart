// Environment Configuration Manager
import 'package:flutter/foundation.dart';
import '../models/ai_provider.dart';

class EnvironmentConfig {
  // Private constructor
  EnvironmentConfig._();
  
  // Singleton instance
  static final EnvironmentConfig _instance = EnvironmentConfig._();
  static EnvironmentConfig get instance => _instance;
  
  // AI Provider Configuration
  static const String _defaultAIProvider = String.fromEnvironment(
    'DEFAULT_AI_PROVIDER',
    defaultValue: 'openai',
  );
  
  // OpenAI Environment variables
  static const String _openAIApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );
  
  static const String _openAIModel = String.fromEnvironment(
    'OPENAI_MODEL',
    defaultValue: 'gpt-3.5-turbo',
  );
  
  static const int _openAIMaxTokens = int.fromEnvironment(
    'OPENAI_MAX_TOKENS',
    defaultValue: 800,
  );
  
  static const double _openAITemperature = 0.7; // Can't use fromEnvironment with double
  
  // Gemini Environment variables
  static const String _geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
  
  static const String _geminiModel = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-1.5-flash',
  );
  
  static const int _geminiMaxTokens = int.fromEnvironment(
    'GEMINI_MAX_TOKENS',
    defaultValue: 800,
  );
  
  static const double _geminiTemperature = 0.7;
  
  // App Configuration
  static const String _appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'LetterAI',
  );
  
  static const String _appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );
  
  static const bool _enableAIFeatures = bool.fromEnvironment(
    'ENABLE_AI_FEATURES',
    defaultValue: true,
  );
  
  static const bool _enablePDFExport = bool.fromEnvironment(
    'ENABLE_PDF_EXPORT',
    defaultValue: true,
  );
  
  static const bool _enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: false,
  );
  
  static const bool _debugMode = bool.fromEnvironment(
    'DEBUG_MODE',
    defaultValue: kDebugMode,
  );
  
  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.openai.com/v1',
  );
  
  static const int _apiTimeout = int.fromEnvironment(
    'API_TIMEOUT',
    defaultValue: 30000,
  );
  
  static const int _maxLettersCache = int.fromEnvironment(
    'MAX_LETTERS_CACHE',
    defaultValue: 100,
  );
  
  static const int _autoSaveInterval = int.fromEnvironment(
    'AUTO_SAVE_INTERVAL',
    defaultValue: 30000,
  );
  
  static const String _defaultPDFTemplate = String.fromEnvironment(
    'DEFAULT_PDF_TEMPLATE',
    defaultValue: 'modern',
  );
  
  static const String _defaultFontFamily = String.fromEnvironment(
    'DEFAULT_FONT_FAMILY',
    defaultValue: 'handwriting',
  );
  
  static const bool _encryptionEnabled = bool.fromEnvironment(
    'ENCRYPTION_ENABLED',
    defaultValue: true,
  );
  
  // Getters for AI Configuration
  AIProvider get defaultAIProvider => AIProviderExtension.fromString(_defaultAIProvider);
  
  AIProviderConfig get openAIConfig => AIProviderConfig(
    provider: AIProvider.openai,
    apiKey: _openAIApiKey,
    model: _openAIModel,
    maxTokens: _openAIMaxTokens,
    temperature: _openAITemperature,
  );
  
  AIProviderConfig get geminiConfig => AIProviderConfig(
    provider: AIProvider.gemini,
    apiKey: _geminiApiKey,
    model: _geminiModel,
    maxTokens: _geminiMaxTokens,
    temperature: _geminiTemperature,
  );
  
  AIProviderConfig getProviderConfig(AIProvider provider) {
    switch (provider) {
      case AIProvider.openai:
        return openAIConfig;
      case AIProvider.gemini:
        return geminiConfig;
    }
  }
  
  // Legacy getters for backward compatibility
  String get openAIApiKey => _openAIApiKey;
  String get openAIModel => _openAIModel;
  int get openAIMaxTokens => _openAIMaxTokens;
  double get openAITemperature => _openAITemperature;
  
  String get appName => _appName;
  String get appVersion => _appVersion;
  
  bool get enableAIFeatures => _enableAIFeatures;
  bool get enablePDFExport => _enablePDFExport;
  bool get enableAnalytics => _enableAnalytics;
  bool get debugMode => _debugMode;
  
  String get apiBaseUrl => _apiBaseUrl;
  int get apiTimeout => _apiTimeout;
  
  int get maxLettersCache => _maxLettersCache;
  int get autoSaveInterval => _autoSaveInterval;
  
  String get defaultPDFTemplate => _defaultPDFTemplate;
  String get defaultFontFamily => _defaultFontFamily;
  
  bool get encryptionEnabled => _encryptionEnabled;
  
  // Validation
  bool get isConfigValid {
    if (_enableAIFeatures && _openAIApiKey.isEmpty) {
      return false;
    }
    return true;
  }
  
  // Debug info
  Map<String, dynamic> getDebugInfo() {
    return {
      'app_name': _appName,
      'app_version': _appVersion,
      'debug_mode': _debugMode,
      'ai_features_enabled': _enableAIFeatures,
      'pdf_export_enabled': _enablePDFExport,
      'analytics_enabled': _enableAnalytics,
      'encryption_enabled': _encryptionEnabled,
      'api_base_url': _apiBaseUrl,
      'has_api_key': _openAIApiKey.isNotEmpty,
    };
  }
}
