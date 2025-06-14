import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/letter_category.dart';
import '../providers/letter_provider.dart';

class AIAssistantPanel extends StatefulWidget {
  final LetterCategory category;
  final LetterSubcategory subcategory;
  final Function(String) onContentGenerated;
  final String currentContent;

  const AIAssistantPanel({
    super.key,
    required this.category,
    required this.subcategory,
    required this.onContentGenerated,
    required this.currentContent,
  });

  @override
  State<AIAssistantPanel> createState() => _AIAssistantPanelState();
}

class _AIAssistantPanelState extends State<AIAssistantPanel> {
  final TextEditingController _promptController = TextEditingController();
  String _selectedTone = 'professional';
  bool _isGenerating = false;
  final List<String> _suggestions = [];

  final List<String> _tones = [
    'professional',
    'formal',
    'friendly',
    'casual',
    'persuasive',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Assistant',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    // Close panel - this would be handled by parent widget
                  },
                  icon: const Icon(Icons.close),
                  iconSize: 20,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Quick action chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _getQuickActions(),
            ),
            
            const SizedBox(height: 16),
            
            // Tone selection
            Row(
              children: [
                Text(
                  'Tone:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedTone,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                    items: _tones.map((tone) {
                      return DropdownMenuItem(
                        value: tone,
                        child: Text(tone.capitalize()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedTone = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Custom prompt input
            TextField(
              controller: _promptController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Describe what you want to add or improve...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: _isGenerating ? null : _generateContent,
                  icon: _isGenerating 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                ),
              ),
              onSubmitted: _isGenerating ? null : (_) => _generateContent(),
            ),
            
            const SizedBox(height: 16),
            
            // Generated suggestions
            if (_suggestions.isNotEmpty) ...[
              Text(
                'Suggestions:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    return _buildSuggestionCard(suggestion, index);
                  },
                ),
              ),
            ] else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Use quick actions or describe what you need help with',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getQuickActions() {
    final actions = <String>[];
    
    // Add context-specific quick actions based on subcategory
    switch (widget.subcategory.id) {
      case 'job_applications':
        actions.addAll(['Add Skills', 'Improve Opening', 'Add Closing', 'Make More Persuasive']);
        break;
      case 'resignation':
        actions.addAll(['Add Gratitude', 'Suggest Transition', 'Make More Professional', 'Add Notice Period']);
        break;
      case 'thank_you':
        actions.addAll(['Express Gratitude', 'Add Personal Touch', 'Suggest Closing', 'Make Warmer']);
        break;
      case 'complaints':
        actions.addAll(['State Problem Clearly', 'Add Solution', 'Make More Diplomatic', 'Add Evidence']);
        break;
      default:
        actions.addAll(['Improve Writing', 'Add Details', 'Make More Professional', 'Suggest Closing']);
    }
    
    return actions.map((action) => _buildQuickActionChip(action)).toList();
  }

  Widget _buildQuickActionChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () => _quickAction(label),
      avatar: Icon(
        Icons.flash_on,
        size: 16,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildSuggestionCard(String suggestion, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              suggestion,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    widget.onContentGenerated(suggestion);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Content added to letter')),
                    );
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Use'),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _suggestions.removeAt(index);
                    });
                  },
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Dismiss'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateContent() async {
    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a prompt')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final provider = context.read<LetterProvider>();
      final content = await provider.generateContent(
        category: widget.category.name,
        subcategory: widget.subcategory.name,
        prompt: _promptController.text.trim(),
        tone: _selectedTone,
      );

      if (content != null) {
        setState(() {
          _suggestions.insert(0, content);
        });
        _promptController.clear();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to generate content. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating content: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  void _quickAction(String action) {
    String prompt = '';
    
    // Generate prompts based on the action and current context
    switch (action) {
      case 'Add Skills':
        prompt = 'Add relevant skills and qualifications for a ${widget.subcategory.name}';
        break;
      case 'Improve Opening':
        prompt = 'Improve the opening paragraph to be more engaging and professional';
        break;
      case 'Add Closing':
        prompt = 'Add a professional closing paragraph for this ${widget.subcategory.name}';
        break;
      case 'Make More Persuasive':
        prompt = 'Make this letter more persuasive and compelling';
        break;
      case 'Make More Professional':
        prompt = 'Make this letter more professional and formal';
        break;
      case 'Add Gratitude':
        prompt = 'Add expressions of gratitude and appreciation';
        break;
      case 'Suggest Transition':
        prompt = 'Add suggestions for transition planning and handover';
        break;
      case 'Add Notice Period':
        prompt = 'Add appropriate notice period information';
        break;
      case 'Express Gratitude':
        prompt = 'Express deeper gratitude and appreciation';
        break;
      case 'Add Personal Touch':
        prompt = 'Add a personal touch while maintaining professionalism';
        break;
      case 'Make Warmer':
        prompt = 'Make the tone warmer and more heartfelt';
        break;
      case 'State Problem Clearly':
        prompt = 'Help clearly state the problem or issue';
        break;
      case 'Add Solution':
        prompt = 'Suggest potential solutions or desired outcomes';
        break;
      case 'Make More Diplomatic':
        prompt = 'Make the tone more diplomatic and constructive';
        break;
      case 'Add Evidence':
        prompt = 'Add space for supporting evidence or documentation';
        break;
      case 'Improve Writing':
        prompt = 'Improve the overall writing quality and clarity';
        break;
      case 'Add Details':
        prompt = 'Add more specific details and information';
        break;
      case 'Suggest Closing':
        prompt = 'Suggest an appropriate closing for this letter';
        break;
      default:
        prompt = action;
    }

    _promptController.text = prompt;
    _generateContent();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
