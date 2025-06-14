import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'settings_service.dart';

// Define exception class for AI errors
class AIException implements Exception {
  final String message;
  AIException(this.message);
  
  @override
  String toString() => 'AIException: $message';
}

// Define WritingSuggestion class
class WritingSuggestion {
  final String originalText;
  final String suggestedText;
  final String type;
  final String explanation;
  
  WritingSuggestion({
    required this.originalText,
    required this.suggestedText,
    required this.type,
    required this.explanation,
  });
}

class AIService {
  static const String _openAIBaseUrl = 'https://api.openai.com/v1';
  final SettingsService _settingsService = SettingsService();
  
  /// Generate letter content using AI
  Future<String> generateLetterContent({
    required String category,
    required String subcategory,
    required String prompt,
    String tone = 'professional',
    int maxTokens = 800,
  }) async {
    print('DEBUG: generateLetterContent called');
    print('Category: $category, Subcategory: $subcategory');
    print('Prompt: $prompt');
    print('Tone: $tone');
    
    final provider = await _settingsService.getAIProvider();
    final apiKey = await _settingsService.getApiKeyForProvider(provider);
    
    print('DEBUG: Provider: $provider');
    print('DEBUG: API Key exists: ${apiKey != null && apiKey.isNotEmpty}');
    
    if (apiKey == null || apiKey.isEmpty) {
      final providerName = provider == AIProviderType.openai ? 'OpenAI' : 'Gemini';
      print('ERROR: API key not configured for $providerName');
      throw AIException('$providerName API key not configured');
    }

    switch (provider) {
      case AIProviderType.openai:
        return await _generateWithOpenAI(
          category: category,
          subcategory: subcategory,
          prompt: prompt,
          tone: tone,
          maxTokens: maxTokens,
          apiKey: apiKey,
        );
      case AIProviderType.gemini:
        return await _generateWithGemini(
          category: category,
          subcategory: subcategory,
          prompt: prompt,
          tone: tone,
          maxTokens: maxTokens,
          apiKey: apiKey,
        );
    }
  }

  /// Generate content using OpenAI
  Future<String> _generateWithOpenAI({
    required String category,
    required String subcategory,
    required String prompt,
    required String tone,
    required int maxTokens,
    required String apiKey,
  }) async {
    try {
      // Get selected model from settings
      final selectedModel = await _settingsService.getOpenAIModel();
      
      final response = await http.post(
        Uri.parse('$_openAIBaseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': selectedModel,
          'messages': [
            {
              'role': 'system',
              'content': _getSystemPrompt(category, subcategory, tone),
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'max_tokens': maxTokens,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        final errorData = jsonDecode(response.body);
        throw AIException('OpenAI API Error: ${errorData['error']['message']}');
      }
    } catch (e) {
      if (e is AIException) {
        rethrow;
      }
      throw AIException('Failed to generate content with OpenAI');
    }
  }

  /// Generate content using Gemini
  Future<String> _generateWithGemini({
    required String category,
    required String subcategory,
    required String prompt,
    required String tone,
    required int maxTokens,
    required String apiKey,
  }) async {
    try {
      // Get selected model from settings
      final selectedModel = await _settingsService.getGeminiModel();
      
      final model = GenerativeModel(
        model: selectedModel,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          maxOutputTokens: maxTokens,
          temperature: 0.7,
        ),
      );

      final systemPrompt = _getSystemPrompt(category, subcategory, tone);
      final fullPrompt = '$systemPrompt\n\nUser request: $prompt';

      final response = await model.generateContent([Content.text(fullPrompt)]);
      
      if (response.text != null) {
        return response.text!.trim();
      } else {
        throw AIException('Gemini returned empty response');
      }
    } catch (e) {
      if (e is AIException) {
        rethrow;
      }
      throw AIException('Failed to generate content with Gemini: ${e.toString()}');
    }
  }
  
  /// Enhance existing text with AI suggestions
  Future<List<String>> enhanceText({
    required String text,
    required String context,
    int suggestionCount = 3,
  }) async {
    final provider = await _settingsService.getAIProvider();
    final apiKey = await _settingsService.getApiKeyForProvider(provider);
    
    if (apiKey == null || apiKey.isEmpty) {
      final providerName = provider == AIProviderType.openai ? 'OpenAI' : 'Gemini';
      throw AIException('$providerName API key not configured');
    }

    switch (provider) {
      case AIProviderType.openai:
        return await _enhanceWithOpenAI(
          text: text,
          context: context,
          suggestionCount: suggestionCount,
          apiKey: apiKey,
        );
      case AIProviderType.gemini:
        return await _enhanceWithGemini(
          text: text,
          context: context,
          suggestionCount: suggestionCount,
          apiKey: apiKey,
        );
    }
  }

  /// Enhance text using OpenAI
  Future<List<String>> _enhanceWithOpenAI({
    required String text,
    required String context,
    required int suggestionCount,
    required String apiKey,
  }) async {
    try {
      // Get selected model from settings
      final selectedModel = await _settingsService.getOpenAIModel();
      
      final response = await http.post(
        Uri.parse('$_openAIBaseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': selectedModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a professional writing assistant. Provide $suggestionCount different improved versions of the given text while maintaining the original meaning and context.',
            },
            {
              'role': 'user',
              'content': 'Context: $context\n\nText to enhance: $text\n\nPlease provide $suggestionCount improved versions, each on a new line starting with a number.',
            },
          ],
          'max_tokens': 600,
          'temperature': 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return _parseSuggestions(content);
      } else {
        final errorData = jsonDecode(response.body);
        throw AIException('OpenAI API Error: ${errorData['error']['message']}');
      }
    } catch (e) {
      if (e is AIException) {
        rethrow;
      }
      throw AIException('Failed to enhance text with OpenAI');
    }
  }

  /// Enhance text using Gemini
  Future<List<String>> _enhanceWithGemini({
    required String text,
    required String context,
    required int suggestionCount,
    required String apiKey,
  }) async {
    try {
      // Get selected model from settings
      final selectedModel = await _settingsService.getGeminiModel();
      
      final model = GenerativeModel(
        model: selectedModel,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          maxOutputTokens: 600,
          temperature: 0.8,
        ),
      );

      final prompt = '''You are a professional writing assistant. Provide $suggestionCount different improved versions of the given text while maintaining the original meaning and context.

Context: $context

Text to enhance: $text

Please provide $suggestionCount improved versions, each on a new line starting with a number.''';

      final response = await model.generateContent([Content.text(prompt)]);
      
      if (response.text != null) {
        return _parseSuggestions(response.text!);
      } else {
        throw AIException('Gemini returned empty response');
      }
    } catch (e) {
      if (e is AIException) {
        rethrow;
      }
      throw AIException('Failed to enhance text with Gemini: ${e.toString()}');
    }
  }
  
  /// Generate letter outline
  Future<Map<String, String>> generateLetterOutline({
    required String category,
    required String subcategory,
    required String purpose,
    String tone = 'professional',
  }) async {
    final provider = await _settingsService.getAIProvider();
    final apiKey = await _settingsService.getApiKeyForProvider(provider);
    
    if (apiKey == null || apiKey.isEmpty) {
      final providerName = provider == AIProviderType.openai ? 'OpenAI' : 'Gemini';
      throw AIException('$providerName API key not configured');
    }

    switch (provider) {
      case AIProviderType.openai:
        return await _generateOutlineWithOpenAI(
          category: category,
          subcategory: subcategory,
          purpose: purpose,
          tone: tone,
          apiKey: apiKey,
        );
      case AIProviderType.gemini:
        return await _generateOutlineWithGemini(
          category: category,
          subcategory: subcategory,
          purpose: purpose,
          tone: tone,
          apiKey: apiKey,
        );
    }
  }

  /// Generate outline using OpenAI
  Future<Map<String, String>> _generateOutlineWithOpenAI({
    required String category,
    required String subcategory,
    required String purpose,
    required String tone,
    required String apiKey,
  }) async {
    try {
      // Get selected model from settings
      final selectedModel = await _settingsService.getOpenAIModel();
      
      final response = await http.post(
        Uri.parse('$_openAIBaseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': selectedModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a professional letter writing assistant. Create a structured outline for a letter including: Introduction, Body paragraphs, and Conclusion. Provide brief guidance for each section.',
            },
            {
              'role': 'user',
              'content': 'Create an outline for a $subcategory letter in the $category category. Purpose: $purpose. Tone: $tone.',
            },
          ],
          'max_tokens': 400,
          'temperature': 0.6,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return _parseOutline(content);
      } else {
        final errorData = jsonDecode(response.body);
        throw AIException('OpenAI API Error: ${errorData['error']['message']}');
      }
    } catch (e) {
      if (e is AIException) {
        rethrow;
      }
      throw AIException('Failed to generate outline with OpenAI');
    }
  }

  /// Generate outline using Gemini
  Future<Map<String, String>> _generateOutlineWithGemini({
    required String category,
    required String subcategory,
    required String purpose,
    required String tone,
    required String apiKey,
  }) async {
    try {
      // Get selected model from settings
      final selectedModel = await _settingsService.getGeminiModel();
      
      final model = GenerativeModel(
        model: selectedModel,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          maxOutputTokens: 400,
          temperature: 0.6,
        ),
      );

      final prompt = '''You are a professional letter writing assistant. Create a structured outline for a letter including: Introduction, Body paragraphs, and Conclusion. Provide brief guidance for each section.

Create an outline for a $subcategory letter in the $category category. Purpose: $purpose. Tone: $tone.''';

      final response = await model.generateContent([Content.text(prompt)]);
      
      if (response.text != null) {
        return _parseOutline(response.text!);
      } else {
        throw AIException('Gemini returned empty response');
      }
    } catch (e) {
      if (e is AIException) {
        rethrow;
      }
      throw AIException('Failed to generate outline with Gemini: ${e.toString()}');
    }
  }
  
  /// Check grammar and style of text
  Future<List<WritingSuggestion>> checkGrammarAndStyle(String text) async {
    final provider = await _settingsService.getAIProvider();
    final apiKey = await _settingsService.getApiKeyForProvider(provider);
    
    if (apiKey == null || apiKey.isEmpty) {
      final providerName = provider == AIProviderType.openai ? 'OpenAI' : 'Gemini';
      throw AIException('$providerName API key not configured');
    }

    switch (provider) {
      case AIProviderType.openai:
        return await _checkGrammarWithOpenAI(text: text, apiKey: apiKey);
      case AIProviderType.gemini:
        return await _checkGrammarWithGemini(text: text, apiKey: apiKey);
    }
  }

  /// Check grammar using OpenAI
  Future<List<WritingSuggestion>> _checkGrammarWithOpenAI({
    required String text,
    required String apiKey,
  }) async {
    try {
      // Get selected model from settings
      final selectedModel = await _settingsService.getOpenAIModel();
      
      final response = await http.post(
        Uri.parse('$_openAIBaseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': selectedModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a professional writing editor. Analyze the text and provide specific suggestions for grammar, style, clarity, and tone improvements. Format each suggestion as: TYPE: SUGGESTION',
            },
            {
              'role': 'user',
              'content': 'Please analyze this text and provide improvement suggestions:\n\n$text',
            },
          ],
          'max_tokens': 500,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return _parseGrammarSuggestions(content);
      } else {
        final errorData = jsonDecode(response.body);
        throw AIException('OpenAI API Error: ${errorData['error']['message']}');
      }
    } catch (e) {
      if (e is AIException) {
        rethrow;
      }
      throw AIException('Failed to check grammar and style with OpenAI');
    }
  }

  /// Check grammar using Gemini
  Future<List<WritingSuggestion>> _checkGrammarWithGemini({
    required String text,
    required String apiKey,
  }) async {
    try {
      // Get selected model from settings
      final selectedModel = await _settingsService.getGeminiModel();
      
      final model = GenerativeModel(
        model: selectedModel,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          maxOutputTokens: 500,
          temperature: 0.3,
        ),
      );

      final prompt = '''You are a professional writing editor. Analyze the text and provide specific suggestions for grammar, style, clarity, and tone improvements. Format each suggestion as: TYPE: SUGGESTION

Please analyze this text and provide improvement suggestions:

$text''';

      final response = await model.generateContent([Content.text(prompt)]);
      
      if (response.text != null) {
        return _parseGrammarSuggestions(response.text!);
      } else {
        throw AIException('Gemini returned empty response');
      }
    } catch (e) {
      if (e is AIException) {
        rethrow;
      }
      throw AIException('Failed to check grammar and style with Gemini: ${e.toString()}');
    }
  }
  
  /// Generate letter templates for a specific category
  Future<List<String>> generateTemplates({
    required String category,
    required String subcategory,
    int templateCount = 3,
  }) async {
    final provider = await _settingsService.getAIProvider();
    final apiKey = await _settingsService.getApiKeyForProvider(provider);
    
    if (apiKey == null || apiKey.isEmpty) {
      final providerName = provider == AIProviderType.openai ? 'OpenAI' : 'Gemini';
      throw AIException('$providerName API key not configured');
    }

    switch (provider) {
      case AIProviderType.openai:
        return await _generateTemplatesWithOpenAI(
          category: category,
          subcategory: subcategory,
          templateCount: templateCount,
          apiKey: apiKey,
        );
      case AIProviderType.gemini:
        return await _generateTemplatesWithGemini(
          category: category,
          subcategory: subcategory,
          templateCount: templateCount,
          apiKey: apiKey,
        );
    }
  }

  /// Generate templates using OpenAI
  Future<List<String>> _generateTemplatesWithOpenAI({
    required String category,
    required String subcategory,
    required int templateCount,
    required String apiKey,
  }) async {
    try {
      // Get selected model from settings
      final selectedModel = await _settingsService.getOpenAIModel();
      
      final response = await http.post(
        Uri.parse('$_openAIBaseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': selectedModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a professional letter writing assistant. Generate $templateCount different letter templates for the specified category and subcategory. Each template should be complete and ready to customize.',
            },
            {
              'role': 'user',
              'content': 'Generate $templateCount different templates for $subcategory letters in the $category category. Separate each template with "---TEMPLATE---".',
            },
          ],
          'max_tokens': 1200,
          'temperature': 0.8,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return content.split('---TEMPLATE---').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw AIException('OpenAI API Error: ${errorData['error']['message']}');
      }
    } catch (e) {
      if (e is AIException) {
        rethrow;
      }
      throw AIException('Failed to generate templates with OpenAI');
    }
  }

  /// Generate templates using Gemini
  Future<List<String>> _generateTemplatesWithGemini({
    required String category,
    required String subcategory,
    required int templateCount,
    required String apiKey,
  }) async {
    try {
      // Get selected model from settings
      final selectedModel = await _settingsService.getGeminiModel();
      
      final model = GenerativeModel(
        model: selectedModel,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          maxOutputTokens: 1200,
          temperature: 0.8,
        ),
      );

      final prompt = '''You are a professional letter writing assistant. Generate $templateCount different letter templates for the specified category and subcategory. Each template should be complete and ready to customize.

Generate $templateCount different templates for $subcategory letters in the $category category. Separate each template with "---TEMPLATE---".''';

      final response = await model.generateContent([Content.text(prompt)]);
      
      if (response.text != null) {
        return response.text!.split('---TEMPLATE---').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
      } else {
        throw AIException('Gemini returned empty response');
      }
    } catch (e) {
      if (e is AIException) {
        rethrow;
      }
      throw AIException('Failed to generate templates with Gemini: ${e.toString()}');
    }
  }

  /// Check if AI service is configured
  Future<bool> get isConfigured async {
    try {
      final provider = await _settingsService.getAIProvider();
      final apiKey = await _settingsService.getApiKeyForProvider(provider);
      final providerName = provider == AIProviderType.openai ? 'openai' : 'gemini';
      
      print('DEBUG: AI Service Configuration Check');
      print('Provider: $provider');
      print('API Key exists: ${apiKey != null}');
      print('API Key length: ${apiKey?.length ?? 0}');
      print('API Key preview: ${apiKey?.substring(0, apiKey.length > 10 ? 10 : apiKey.length)}...');
      print('Provider name: $providerName');
      
      final isConfigured = apiKey != null && apiKey.isNotEmpty && apiKey != 'your_${providerName}_api_key_here';
      print('Is configured: $isConfigured');
      
      return isConfigured;
    } catch (e) {
      print('ERROR in isConfigured: $e');
      return false;
    }
  }
  
  /// Get fallback content when AI is not available
  String getFallbackContent(String subcategory) {
    const fallbackTemplates = {
      'job_applications': '''Dear Hiring Manager,

I am writing to express my interest in the [Position Title] position at [Company Name]. With my [relevant experience/skills], I believe I would be a valuable addition to your team.

[Body paragraph highlighting relevant experience and achievements]

[Body paragraph explaining why you want to work for the company]

Thank you for considering my application. I look forward to hearing from you.

Sincerely,
[Your Name]''',
      
      'resignation': '''Dear [Manager's Name],

Please accept this letter as formal notification of my resignation from my position as [Job Title] with [Company Name]. My last day will be [Date].

[Optional: Brief reason for leaving]

I am committed to ensuring a smooth transition and am willing to assist in training my replacement.

Thank you for the opportunities for professional and personal growth during my time here.

Sincerely,
[Your Name]''',
      
      'thank_you': '''Dear [Recipient's Name],

I wanted to take a moment to express my sincere gratitude for [specific reason].

[Body paragraph explaining the impact or importance]

Your [kindness/support/assistance] means a great deal to me, and I truly appreciate everything you have done.

Thank you once again.

Warm regards,
[Your Name]''',
      
      'complaints': '''Dear [Recipient's Name],

I am writing to bring to your attention a concern regarding [issue].

[Body paragraph describing the problem in detail]

[Body paragraph suggesting potential solutions]

I would appreciate your prompt attention to this matter and look forward to a resolution.

Sincerely,
[Your Name]''',
    };
    
    return fallbackTemplates[subcategory] ?? '''Dear [Recipient],

[Opening paragraph introducing the purpose of your letter]

[Body paragraph with main content]

[Closing paragraph with next steps or conclusion]

Sincerely,
[Your Name]''';
  }

  /// Get system prompt for specific letter category
  String _getSystemPrompt(String category, String subcategory, String tone) {
    return '''You are a professional letter writing assistant. Generate a well-structured, $tone letter for the $category category, specifically for $subcategory.

Guidelines:
- Use appropriate formatting and structure
- Match the requested tone ($tone)
- Include placeholder text in [brackets] for personalization
- Ensure the content is professional and effective
- Keep the letter concise but comprehensive''';
  }

  /// Parse suggestions from AI response
  List<String> _parseSuggestions(String content) {
    final lines = content.split('\n');
    final suggestions = <String>[];
    
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty && (trimmed.contains(RegExp(r'^\d+\.')) || trimmed.contains(':'))) {
        suggestions.add(trimmed);
      }
    }
    
    return suggestions.isEmpty ? [content.trim()] : suggestions;
  }

  /// Parse grammar suggestions from AI response
  List<WritingSuggestion> _parseGrammarSuggestions(String content) {
    final lines = content.split('\n');
    final suggestions = <WritingSuggestion>[];
    
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty && (trimmed.contains(RegExp(r'^\d+\.')) || trimmed.contains(':'))) {
        suggestions.add(WritingSuggestion(
          originalText: '',
          suggestedText: trimmed,
          type: 'general',
          explanation: 'AI suggestion',
        ));
      }
    }
    
    return suggestions.isEmpty ? [
      WritingSuggestion(
        originalText: '',
        suggestedText: content.trim(),
        type: 'general',
        explanation: 'AI suggestion',
      )
    ] : suggestions;
  }

  /// Parse outline from AI response
  Map<String, String> _parseOutline(String content) {
    final sections = <String, String>{};
    final lines = content.split('\n');
    String currentSection = '';
    String currentContent = '';
    
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      
      if (trimmed.toLowerCase().contains('introduction') || 
          trimmed.toLowerCase().contains('opening')) {
        if (currentSection.isNotEmpty) {
          sections[currentSection] = currentContent.trim();
        }
        currentSection = 'Introduction';
        currentContent = '';
      } else if (trimmed.toLowerCase().contains('body') || 
                 trimmed.toLowerCase().contains('main')) {
        if (currentSection.isNotEmpty) {
          sections[currentSection] = currentContent.trim();
        }
        currentSection = 'Body';
        currentContent = '';
      } else if (trimmed.toLowerCase().contains('conclusion') || 
                 trimmed.toLowerCase().contains('closing')) {
        if (currentSection.isNotEmpty) {
          sections[currentSection] = currentContent.trim();
        }
        currentSection = 'Conclusion';
        currentContent = '';
      } else {
        currentContent += trimmed + '\n';
      }
    }
    
    if (currentSection.isNotEmpty) {
      sections[currentSection] = currentContent.trim();
    }
    
    if (sections.isEmpty) {
      sections['Content'] = content.trim();
    }
    
    return sections;
  }
}
