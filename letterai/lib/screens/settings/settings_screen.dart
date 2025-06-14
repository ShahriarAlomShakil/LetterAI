import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';
import '../../services/ai_service.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  final AIService _aiService = AIService();
  
  // Form controllers
  final _openAIApiKeyController = TextEditingController();
  final _geminiApiKeyController = TextEditingController();
  
  // Settings state
  AIProviderType _selectedProvider = AIProviderType.openai;
  String _selectedOpenAIModel = 'gpt-3.5-turbo';
  String _selectedGeminiModel = 'gemini-1.5-flash';
  String _theme = 'system';
  String _fontSize = 'medium';
  bool _autoSave = true;
  bool _notifications = true;
  String _defaultTone = 'professional';
  
  bool _isLoading = true;
  bool _isSaving = false;
  
  // AI test state
  bool _isTestingAI = false;
  String? _testResult;
  bool? _testSuccess;
  
  // Available models for each provider
  static const Map<String, List<Map<String, String>>> _availableModels = {
    'openai': [
      {'id': 'gpt-3.5-turbo', 'name': 'GPT-3.5 Turbo', 'description': 'Fast and cost-effective'},
      {'id': 'gpt-4', 'name': 'GPT-4', 'description': 'Most capable model'},
      {'id': 'gpt-4-turbo', 'name': 'GPT-4 Turbo', 'description': 'Latest GPT-4 with improved performance'},
      {'id': 'gpt-4o', 'name': 'GPT-4o', 'description': 'Optimized for better performance'},
      {'id': 'gpt-4o-mini', 'name': 'GPT-4o Mini', 'description': 'Smaller, faster GPT-4o'},
    ],
    'gemini': [
      {'id': 'gemini-1.5-flash', 'name': 'Gemini 1.5 Flash', 'description': 'Fast and efficient'},
      {'id': 'gemini-1.5-pro', 'name': 'Gemini 1.5 Pro', 'description': 'Most capable Gemini model'},
      {'id': 'gemini-1.0-pro', 'name': 'Gemini 1.0 Pro', 'description': 'Previous generation'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      // Load all settings
      _selectedProvider = await _settingsService.getAIProvider();
      
      // Get theme from ThemeProvider instead of directly from settings
      final themeProvider = context.read<ThemeProvider>();
      _theme = themeProvider.currentTheme;
      
      _fontSize = await _settingsService.getFontSize();
      _autoSave = await _settingsService.getAutoSave();
      _notifications = await _settingsService.getNotificationsEnabled();
      _defaultTone = await _settingsService.getDefaultTone();
      
      // Load API keys
      final openAIKey = await _settingsService.getOpenAIApiKey();
      final geminiKey = await _settingsService.getGeminiApiKey();
      
      _openAIApiKeyController.text = openAIKey ?? '';
      _geminiApiKeyController.text = geminiKey ?? '';
      
      // Load model preferences
      _selectedOpenAIModel = await _settingsService.getOpenAIModel();
      _selectedGeminiModel = await _settingsService.getGeminiModel();
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading settings: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    
    try {
      // Save AI provider and API keys
      await _settingsService.setAIProvider(_selectedProvider);
      await _settingsService.setOpenAIApiKey(
        _openAIApiKeyController.text.trim().isEmpty 
          ? null 
          : _openAIApiKeyController.text.trim()
      );
      await _settingsService.setGeminiApiKey(
        _geminiApiKeyController.text.trim().isEmpty 
          ? null 
          : _geminiApiKeyController.text.trim()
      );
      
      // Save model preferences
      await _settingsService.setOpenAIModel(_selectedOpenAIModel);
      await _settingsService.setGeminiModel(_selectedGeminiModel);
      
      // Save other settings (theme is handled by ThemeProvider automatically)
      await _settingsService.setFontSize(_fontSize);
      await _settingsService.setAutoSave(_autoSave);
      await _settingsService.setNotificationsEnabled(_notifications);
      await _settingsService.setDefaultTone(_defaultTone);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving settings: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _testAIConnection() async {
    setState(() {
      _isTestingAI = true;
      _testResult = null;
      _testSuccess = null;
    });

    try {
      // First save the current settings to ensure we're testing with the right config
      await _saveCurrentProviderSettings();
      
      // Test if AI service is configured
      final isConfigured = await _aiService.isConfigured;
      if (!isConfigured) {
        setState(() {
          _testResult = 'API key not configured. Please enter a valid API key first.';
          _testSuccess = false;
        });
        return;
      }

      // Test actual AI generation
      final testPrompt = 'Write a simple one-sentence greeting message.';
      final result = await _aiService.generateLetterContent(
        category: 'Test',
        subcategory: 'greeting',
        prompt: testPrompt,
        tone: 'friendly',
        maxTokens: 50,
      );

      // Check if we got a valid response
      if (result.isNotEmpty && result.length > 10) {
        setState(() {
          _testResult = 'Success! AI responded: "${result.length > 100 ? result.substring(0, 97) + '...' : result}"';
          _testSuccess = true;
        });
      } else {
        setState(() {
          _testResult = 'Test failed: Received empty or invalid response from AI.';
          _testSuccess = false;
        });
      }
    } catch (e) {
      setState(() {
        _testResult = 'Test failed: ${e.toString()}';
        _testSuccess = false;
      });
    } finally {
      setState(() {
        _isTestingAI = false;
      });
    }
  }

  Future<void> _saveCurrentProviderSettings() async {
    // Save current provider
    await _settingsService.setAIProvider(_selectedProvider);
    
    // Save the appropriate API key and model
    if (_selectedProvider == AIProviderType.openai) {
      await _settingsService.setOpenAIApiKey(_openAIApiKeyController.text.trim());
      await _settingsService.setOpenAIModel(_selectedOpenAIModel);
    } else {
      await _settingsService.setGeminiApiKey(_geminiApiKeyController.text.trim());
      await _settingsService.setGeminiModel(_selectedGeminiModel);
    }
  }

  List<Map<String, String>> _getAvailableModelsForCurrentProvider() {
    final providerKey = _selectedProvider == AIProviderType.openai ? 'openai' : 'gemini';
    return _availableModels[providerKey] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveSettings,
              child: const Text('Save'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAIProviderSection(),
                  const SizedBox(height: 24),
                  _buildAppearanceSection(),
                  const SizedBox(height: 24),
                  _buildBehaviorSection(),
                  const SizedBox(height: 24),
                  _buildAboutSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildAIProviderSection() {
    return _buildSection(
      title: 'AI Provider Configuration',
      icon: Icons.psychology,
      children: [
        // Provider selection
        ListTile(
          title: const Text('AI Provider'),
          subtitle: Text(_selectedProvider == AIProviderType.openai ? 'OpenAI GPT-3.5 Turbo' : 'Google Gemini Pro'),
          trailing: DropdownButton<AIProviderType>(
            value: _selectedProvider,
            items: AIProviderType.values.map((provider) {
              return DropdownMenuItem(
                value: provider,
                child: Text(provider == AIProviderType.openai ? 'OpenAI' : 'Google Gemini'),
              );
            }).toList(),
            onChanged: (provider) {
              if (provider != null) {
                setState(() => _selectedProvider = provider);
              }
            },
          ),
        ),
        
        const Divider(),
        
        // Model Selection
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.memory, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedProvider == AIProviderType.openai ? 'OpenAI' : 'Gemini'} Model',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedProvider == AIProviderType.openai 
                        ? _selectedOpenAIModel 
                        : _selectedGeminiModel,
                    isExpanded: true,
                    items: _getAvailableModelsForCurrentProvider().map((model) {
                      return DropdownMenuItem<String>(
                        value: model['id'],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              model['name']!,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              model['description']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newModel) {
                      if (newModel != null) {
                        setState(() {
                          if (_selectedProvider == AIProviderType.openai) {
                            _selectedOpenAIModel = newModel;
                          } else {
                            _selectedGeminiModel = newModel;
                          }
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select the AI model to use for content generation.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        const Divider(),
        
        // OpenAI API Key
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.vpn_key, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'OpenAI API Key',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  if (_selectedProvider == AIProviderType.openai)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ACTIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _openAIApiKeyController,
                decoration: InputDecoration(
                  hintText: 'sk-...',
                  border: const OutlineInputBorder(),
                  suffixIcon: _openAIApiKeyController.text.isNotEmpty
                      ? Icon(
                          Icons.check_circle,
                          color: Colors.green.shade600,
                        )
                      : const Icon(Icons.warning, color: Colors.orange),
                ),
                obscureText: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 4),
              Text(
                'Get your API key from platform.openai.com',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Gemini API Key
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.vpn_key, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Google Gemini API Key',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  if (_selectedProvider == AIProviderType.gemini)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ACTIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _geminiApiKeyController,
                decoration: InputDecoration(
                  hintText: 'AIza...',
                  border: const OutlineInputBorder(),
                  suffixIcon: _geminiApiKeyController.text.isNotEmpty
                      ? Icon(
                          Icons.check_circle,
                          color: Colors.green.shade600,
                        )
                      : const Icon(Icons.warning, color: Colors.orange),
                ),
                obscureText: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 4),
              Text(
                'Get your API key from makersuite.google.com',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // AI Test Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.speed, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Test AI Connection',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Test button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isTestingAI ? null : _testAIConnection,
                  icon: _isTestingAI 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                  label: Text(_isTestingAI ? 'Testing...' : 'Test Connection'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              
              // Test result
              if (_testResult != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _testSuccess == true 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                    border: Border.all(
                      color: _testSuccess == true ? Colors.green : Colors.red,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _testSuccess == true ? Icons.check_circle : Icons.error,
                        color: _testSuccess == true ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _testResult!,
                          style: TextStyle(
                            color: _testSuccess == true ? Colors.green.shade700 : Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 8),
              Text(
                'This will test if your API key is working by sending a simple request to the AI service.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return _buildSection(
          title: 'Appearance',
          icon: Icons.palette,
          children: [
            ListTile(
              title: const Text('Theme'),
              subtitle: Text(themeProvider.currentTheme.substring(0, 1).toUpperCase() + 
                            themeProvider.currentTheme.substring(1)),
              trailing: DropdownButton<String>(
                value: themeProvider.currentTheme,
                items: const [
                  DropdownMenuItem(value: 'system', child: Text('System')),
                  DropdownMenuItem(value: 'light', child: Text('Light')),
                  DropdownMenuItem(value: 'dark', child: Text('Dark')),
                ],
                onChanged: (value) async {
                  if (value != null) {
                    await themeProvider.setTheme(value);
                    // Update local state for consistency
                    setState(() => _theme = value);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Font Size'),
              subtitle: Text(_fontSize.substring(0, 1).toUpperCase() + _fontSize.substring(1)),
              trailing: DropdownButton<String>(
                value: _fontSize,
                items: const [
                  DropdownMenuItem(value: 'small', child: Text('Small')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'large', child: Text('Large')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _fontSize = value);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBehaviorSection() {
    return _buildSection(
      title: 'Behavior',
      icon: Icons.tune,
      children: [
        SwitchListTile(
          title: const Text('Auto-save'),
          subtitle: const Text('Automatically save changes'),
          value: _autoSave,
          onChanged: (value) {
            setState(() => _autoSave = value);
          },
        ),
        SwitchListTile(
          title: const Text('Notifications'),
          subtitle: const Text('Enable app notifications'),
          value: _notifications,
          onChanged: (value) {
            setState(() => _notifications = value);
          },
        ),
        ListTile(
          title: const Text('Default Tone'),
          subtitle: Text(_defaultTone.substring(0, 1).toUpperCase() + _defaultTone.substring(1)),
          trailing: DropdownButton<String>(
            value: _defaultTone,
            items: const [
              DropdownMenuItem(value: 'professional', child: Text('Professional')),
              DropdownMenuItem(value: 'formal', child: Text('Formal')),
              DropdownMenuItem(value: 'friendly', child: Text('Friendly')),
              DropdownMenuItem(value: 'casual', child: Text('Casual')),
              DropdownMenuItem(value: 'persuasive', child: Text('Persuasive')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _defaultTone = value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      title: 'About',
      icon: Icons.info,
      children: [
        const ListTile(
          title: Text('LetterAI'),
          subtitle: Text('Version 1.0.0'),
          trailing: Icon(Icons.app_registration),
        ),
        ListTile(
          title: const Text('Reset Settings'),
          subtitle: const Text('Clear all preferences (keeps API keys)'),
          trailing: const Icon(Icons.refresh),
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Reset Settings'),
                content: const Text(
                  'This will reset all preferences to default values. API keys will be preserved.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Reset'),
                  ),
                ],
              ),
            );
            
            if (confirm == true) {
              await _settingsService.resetToDefaults();
              await _loadSettings();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings reset successfully')),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _openAIApiKeyController.dispose();
    _geminiApiKeyController.dispose();
    super.dispose();
  }
}
