enum AIProvider {
  openai,
  gemini,
}

extension AIProviderExtension on AIProvider {
  String get name {
    switch (this) {
      case AIProvider.openai:
        return 'OpenAI';
      case AIProvider.gemini:
        return 'Google Gemini';
    }
  }

  String get description {
    switch (this) {
      case AIProvider.openai:
        return 'OpenAI GPT-3.5 Turbo';
      case AIProvider.gemini:
        return 'Google Gemini Pro';
    }
  }

  String get apiKeyKey {
    switch (this) {
      case AIProvider.openai:
        return 'OPENAI_API_KEY';
      case AIProvider.gemini:
        return 'GEMINI_API_KEY';
    }
  }

  String get modelKey {
    switch (this) {
      case AIProvider.openai:
        return 'OPENAI_MODEL';
      case AIProvider.gemini:
        return 'GEMINI_MODEL';
    }
  }

  String get defaultModel {
    switch (this) {
      case AIProvider.openai:
        return 'gpt-3.5-turbo';
      case AIProvider.gemini:
        return 'gemini-1.5-flash';
    }
  }

  static AIProvider fromString(String value) {
    switch (value.toLowerCase()) {
      case 'openai':
        return AIProvider.openai;
      case 'gemini':
        return AIProvider.gemini;
      default:
        return AIProvider.openai;
    }
  }

  String get stringValue {
    switch (this) {
      case AIProvider.openai:
        return 'openai';
      case AIProvider.gemini:
        return 'gemini';
    }
  }
}

class AIProviderConfig {
  final AIProvider provider;
  final String apiKey;
  final String model;
  final int maxTokens;
  final double temperature;

  const AIProviderConfig({
    required this.provider,
    required this.apiKey,
    required this.model,
    this.maxTokens = 800,
    this.temperature = 0.7,
  });

  bool get isConfigured => apiKey.isNotEmpty && apiKey != 'your_${provider}_api_key_here';

  AIProviderConfig copyWith({
    AIProvider? provider,
    String? apiKey,
    String? model,
    int? maxTokens,
    double? temperature,
  }) {
    return AIProviderConfig(
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      maxTokens: maxTokens ?? this.maxTokens,
      temperature: temperature ?? this.temperature,
    );
  }
}
