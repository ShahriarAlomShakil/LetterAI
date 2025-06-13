import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // Note: In production, move API keys to environment variables or secure storage
  static const String _openAIBaseUrl = 'https://api.openai.com/v1';
  static const String _apiKey = 'YOUR_OPENAI_API_KEY'; // Replace with actual API key
  
  /// Generate letter content using AI
  Future<String> generateLetterContent({
    required String category,
    required String subcategory,
    required String prompt,
    String tone = 'professional',
    int maxTokens = 800,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_openAIBaseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
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
          'top_p': 1.0,
          'frequency_penalty': 0.0,
          'presence_penalty': 0.0,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return content.trim();
      } else {
        throw const AIException('OpenAI API Error: Unknown error');
      }
    } catch (e) {
      if (e is AIException) {
        rethrow;
      }
      throw const AIException('Failed to generate content');
    }
  }
  
  /// Enhance existing text with AI suggestions
  Future<List<String>> enhanceText({
    required String text,
    required String context,
    int suggestionCount = 3,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_openAIBaseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
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
        return _parseEnhancements(content);
      } else {
        throw const AIException('Failed to enhance text');
      }
    } catch (e) {
      if (e is AIException) {
        rethrow;
      }
      throw const AIException('Failed to enhance text');
    }
  }
  
  /// Generate letter outline based on requirements
  Future<Map<String, String>> generateLetterOutline({
    required String category,
    required String subcategory,
    required String purpose,
    String tone = 'professional',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_openAIBaseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a professional letter writing assistant. Create a structured outline for a letter including: Introduction, Body paragraphs, and Conclusion. Provide brief guidance for each section.',
            },
            {
              'role': 'user',
              'content': 'Create an outline for a $tone $subcategory letter in the $category category. Purpose: $purpose',
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
        throw const AIException('Failed to generate outline');
      }
    } catch (e) {
      if (e is AIException) {
        rethrow;
      }
      throw const AIException('Failed to generate outline');
    }
  }
  
  /// Check grammar and style of text
  Future<List<WritingSuggestion>> checkGrammarAndStyle(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$_openAIBaseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
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
        return _parseSuggestions(content);
      } else {
        throw const AIException('Failed to check grammar and style');
      }
    } catch (e) {
      if (e is AIException) {
        rethrow;
      }
      throw const AIException('Failed to check grammar and style');
    }
  }
  
  /// Generate letter templates for a specific category
  Future<List<String>> generateTemplates({
    required String category,
    required String subcategory,
    int templateCount = 3,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_openAIBaseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
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
        throw const AIException('Failed to generate templates');
      }
    } catch (e) {
      if (e is AIException) {
        rethrow;
      }
      throw const AIException('Failed to generate templates');
    }
  }
  
  /// Get system prompt based on category and tone
  String _getSystemPrompt(String category, String subcategory, String tone) {
    return '''You are a professional letter writing assistant specialized in creating high-quality, well-structured letters.

Category: $category
Subcategory: $subcategory
Tone: $tone

Guidelines:
- Create a complete, professional letter
- Use appropriate formatting and structure
- Include proper salutation and closing
- Maintain the specified tone throughout
- Ensure the content is relevant to the category and subcategory
- Make the letter ready to send with minimal customization needed
- Include placeholder fields in square brackets [like this] where personalization is needed

Please write a comprehensive letter based on the user's requirements.''';
  }
  
  /// Parse enhancement suggestions from AI response
  List<String> _parseEnhancements(String content) {
    final lines = content.split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
    
    final enhancements = <String>[];
    for (final line in lines) {
      if (RegExp(r'^\d+\.?\s*').hasMatch(line)) {
        enhancements.add(line.replaceFirst(RegExp(r'^\d+\.?\s*'), '').trim());
      }
    }
    
    return enhancements.isNotEmpty ? enhancements : [content.trim()];
  }
  
  /// Parse outline from AI response
  Map<String, String> _parseOutline(String content) {
    final outline = <String, String>{};
    final sections = ['Introduction', 'Body', 'Conclusion'];
    
    String currentSection = '';
    final lines = content.split('\n');
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;
      
      // Check if line contains a section header
      final matchedSection = sections.firstWhere(
        (section) => trimmedLine.toLowerCase().contains(section.toLowerCase()),
        orElse: () => '',
      );
      
      if (matchedSection.isNotEmpty) {
        currentSection = matchedSection;
        outline[currentSection] = '';
      } else if (currentSection.isNotEmpty) {
        if (outline[currentSection]!.isNotEmpty) {
          outline[currentSection] = '${outline[currentSection]}\n$trimmedLine';
        } else {
          outline[currentSection] = trimmedLine;
        }
      }
    }
    
    // If parsing failed, return the whole content as body
    if (outline.isEmpty) {
      outline['Body'] = content.trim();
    }
    
    return outline;
  }
  
  /// Parse writing suggestions from AI response
  List<WritingSuggestion> _parseSuggestions(String content) {
    final suggestions = <WritingSuggestion>[];
    final lines = content.split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
    
    for (final line in lines) {
      if (line.contains(':')) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          final type = parts[0].trim();
          final suggestion = parts.sublist(1).join(':').trim();        suggestions.add(WritingSuggestion(
          type: type,
          suggestion: suggestion,
        ));
        }
      }
    }
    
    return suggestions;
  }
  
  /// Check if API key is configured
  bool get isConfigured => _apiKey != 'YOUR_OPENAI_API_KEY' && _apiKey.isNotEmpty;
  
  /// Get fallback content when AI is not available
  String getFallbackContent(String subcategory) {
    const fallbackTemplates = {
      'job_applications': '''Dear Hiring Manager,

I am writing to express my interest in the [Position Title] position at [Company Name]. With my [relevant experience/skills], I believe I would be a valuable addition to your team.

[Body paragraph highlighting relevant experience and achievements]

[Body paragraph explaining why you want to work for the company]

I have attached my resume for your review and would welcome the opportunity to discuss how my background and enthusiasm can contribute to [Company Name]. Thank you for your time and consideration.

Sincerely,
[Your Name]''',
      
      'thank_you': '''Dear [Recipient Name],

I wanted to take a moment to express my heartfelt gratitude for [specific reason for thanks].

[Body paragraph with specific details about what you're thankful for]

Your [kindness/help/support] has made a significant difference, and I truly appreciate everything you've done.

With sincere appreciation,
[Your Name]''',
      
      'resignation': '''Dear [Manager's Name],

Please accept this letter as my formal notice of resignation from my position as [Job Title] with [Company Name]. My last day of employment will be [Date].

[Body paragraph expressing gratitude and offering transition assistance]

I am committed to ensuring a smooth transition and am willing to assist in training my replacement.

Thank you for the opportunities for professional and personal growth during my time here.

Sincerely,
[Your Name]''',
    };
    
    return fallbackTemplates[subcategory] ?? '''Dear [Recipient],

[Opening paragraph stating the purpose of your letter]

[Body paragraph with main content]

[Closing paragraph with next steps or call to action]

Sincerely,
[Your Name]''';
  }
}

/// Model for writing suggestions
class WritingSuggestion {
  final String type;
  final String suggestion;
  
  const WritingSuggestion({
    required this.type,
    required this.suggestion,
  });
  
  @override
  String toString() => '$type: $suggestion';
}

/// Custom exception for AI service operations
class AIException implements Exception {
  final String message;
  
  const AIException(this.message);
  
  @override
  String toString() => 'AIException: $message';
}
