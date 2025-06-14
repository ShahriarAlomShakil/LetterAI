import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../services/settings_service.dart';

class AITestScreen extends StatefulWidget {
  const AITestScreen({super.key});

  @override
  State<AITestScreen> createState() => _AITestScreenState();
}

class _AITestScreenState extends State<AITestScreen> {
  final AIService _aiService = AIService();
  final SettingsService _settingsService = SettingsService();
  
  String _testResults = '';
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Configuration Test'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'AI Chatbot Debug Tool',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Use this tool to diagnose why the AI chatbot is not responding. This will check your API configuration and test the AI service.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRunning ? null : _runComprehensiveTest,
                    icon: _isRunning 
                      ? const SizedBox(
                          width: 16, 
                          height: 16, 
                          child: CircularProgressIndicator(strokeWidth: 2)
                        )
                      : const Icon(Icons.play_arrow),
                    label: Text(_isRunning ? 'Testing...' : 'Run Diagnostic Test'),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _clearResults,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Test Results:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResults.isEmpty ? 'No tests run yet. Click "Run Diagnostic Test" to start.' : _testResults,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Quick Actions:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                    child: const Text('Open Settings'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/'),
                    child: const Text('Go to Home'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _clearResults() {
    setState(() {
      _testResults = '';
    });
  }

  void _appendResult(String message) {
    setState(() {
      _testResults += '$message\n';
    });
  }

  Future<void> _runComprehensiveTest() async {
    setState(() {
      _isRunning = true;
      _testResults = 'Starting comprehensive AI test...\n\n';
    });

    try {
      // Test 1: Check settings service
      _appendResult('=== SETTINGS SERVICE TEST ===');
      final provider = await _settingsService.getAIProvider();
      _appendResult('Current AI Provider: $provider');
      
      final openaiKey = await _settingsService.getOpenAIApiKey();
      _appendResult('OpenAI API Key: ${openaiKey != null ? 'exists (${openaiKey.length} chars)' : 'not set'}');
      if (openaiKey != null) {
        _appendResult('OpenAI Key Preview: ${openaiKey.substring(0, openaiKey.length > 10 ? 10 : openaiKey.length)}...');
      }
      
      final geminiKey = await _settingsService.getGeminiApiKey();
      _appendResult('Gemini API Key: ${geminiKey != null ? 'exists (${geminiKey.length} chars)' : 'not set'}');
      if (geminiKey != null) {
        _appendResult('Gemini Key Preview: ${geminiKey.substring(0, geminiKey.length > 10 ? 10 : geminiKey.length)}...');
      }
      
      final providerKey = await _settingsService.getApiKeyForProvider(provider);
      _appendResult('Provider-specific key: ${providerKey != null ? 'exists (${providerKey.length} chars)' : 'not set'}');
      
      // Test 2: Check AI service configuration
      _appendResult('\n=== AI SERVICE CONFIGURATION ===');
      final isConfigured = await _aiService.isConfigured;
      _appendResult('AI Service Configured: $isConfigured');
      
      // Test 3: Test AI service directly if configured
      if (isConfigured) {
        _appendResult('\n=== AI SERVICE TEST ===');
        try {
          final testContent = await _aiService.generateLetterContent(
            category: 'Business',
            subcategory: 'Thank You',
            prompt: 'Write a simple thank you letter',
            tone: 'professional',
            maxTokens: 100,
          );
          _appendResult('✅ AI Service Test PASSED');
          _appendResult('Response length: ${testContent.length} characters');
          _appendResult('Response preview: ${testContent.substring(0, testContent.length > 100 ? 100 : testContent.length)}...');
        } catch (e) {
          _appendResult('❌ AI Service Test FAILED: $e');
        }
      } else {
        _appendResult('\n=== FALLBACK CONTENT TEST ===');
        final fallback = _aiService.getFallbackContent('thank_you');
        _appendResult('Fallback content available: ${fallback.isNotEmpty}');
        _appendResult('Fallback length: ${fallback.length} characters');
      }
      
      // Test 4: Provide configuration guidance
      _appendResult('\n=== CONFIGURATION GUIDANCE ===');
      if (!isConfigured) {
        _appendResult('🔧 To configure AI:');
        _appendResult('1. Go to Settings screen');
        _appendResult('2. Select AI Provider (OpenAI or Gemini)');
        _appendResult('3. Enter your API key');
        _appendResult('4. Return to letter writing and test chatbot');
        
        if (provider == AIProviderType.openai) {
          _appendResult('\n📝 For OpenAI:');
          _appendResult('- Get API key from: https://platform.openai.com/api-keys');
          _appendResult('- Key format: sk-...');
        } else {
          _appendResult('\n📝 For Gemini:');
          _appendResult('- Get API key from: https://makersuite.google.com/app/apikey');
          _appendResult('- Key format: AI...');
        }
      } else {
        _appendResult('✅ AI is properly configured!');
        _appendResult('You can now use the chatbot in letter writing screens.');
      }
      
    } catch (e) {
      _appendResult('❌ Test failed with error: $e');
    }
    
    setState(() {
      _isRunning = false;
    });
  }
}
