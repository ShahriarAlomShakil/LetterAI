import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import '../../models/letter.dart';
import '../../models/letter_category.dart';
import '../../providers/letter_provider.dart';
import '../../widgets/ai_assistant_panel.dart';
import '../../widgets/ai_chatbot_widget.dart';
import '../pdf/pdf_preview_screen.dart';

class LetterEditorScreen extends StatefulWidget {
  final LetterCategory category;
  final LetterSubcategory subcategory;
  final Letter? existingLetter;

  const LetterEditorScreen({
    super.key,
    required this.category,
    required this.subcategory,
    this.existingLetter,
  });

  @override
  State<LetterEditorScreen> createState() => _LetterEditorScreenState();
}

class _LetterEditorScreenState extends State<LetterEditorScreen> {
  late QuillController _controller;
  late TextEditingController _titleController;
  bool _showAIPanel = false;
  bool _showChatbot = false;
  bool _hasUnsavedChanges = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
    _titleController = TextEditingController();
    
    if (widget.existingLetter != null) {
      _titleController.text = widget.existingLetter!.title;
      // For now, we'll just set plain text. In a full implementation,
      // you'd convert from stored format to Quill Delta
      _controller.document = Document()..insert(0, widget.existingLetter!.content);
    } else {
      // Set a default title based on subcategory
      _titleController.text = _getDefaultTitle();
      // Load initial content template
      _loadInitialContent();
    }
    
    _controller.addListener(_onContentChanged);
    _titleController.addListener(_onContentChanged);
  }

  String _getDefaultTitle() {
    switch (widget.subcategory.id) {
      case 'job_applications':
        return 'Job Application Letter';
      case 'resignation':
        return 'Resignation Letter';
      case 'thank_you':
        return 'Thank You Letter';
      case 'complaints':
        return 'Complaint Letter';
      default:
        return widget.subcategory.name;
    }
  }

  void _loadInitialContent() {
    // Load a basic template based on subcategory
    final template = _getTemplate(widget.subcategory.id);
    _controller.document = Document()..insert(0, template);
  }

  String _getTemplate(String subcategoryId) {
    switch (subcategoryId) {
      case 'job_applications':
        return '''Dear Hiring Manager,

I am writing to express my interest in the [Position Title] position at [Company Name]. With my background in [Your Field/Experience], I believe I would be a valuable addition to your team.

[Add your qualifications and experience here]

I have attached my resume for your review and would welcome the opportunity to discuss how my skills and experience align with your team's needs.

Thank you for your time and consideration.

Sincerely,
[Your Name]''';

      case 'resignation':
        return '''Dear [Manager's Name],

Please accept this letter as formal notification of my resignation from my position as [Your Job Title] with [Company Name]. My last day of employment will be [Date].

I am grateful for the opportunities for professional and personal growth during my time here. I appreciate the support and guidance you have provided me.

During my remaining time, I will do everything possible to ensure a smooth transition of my responsibilities.

Thank you for your understanding.

Sincerely,
[Your Name]''';

      case 'thank_you':
        return '''Dear [Recipient Name],

I wanted to take a moment to express my sincere gratitude for [specific reason for thanks].

[Add personal details about what you're thankful for]

Your [kindness/support/help] has meant a great deal to me, and I truly appreciate it.

Thank you again for everything.

With warm regards,
[Your Name]''';

      case 'complaints':
        return '''Dear [Recipient/Company Name],

I am writing to bring to your attention an issue I experienced with [product/service] on [date].

[Describe the problem clearly and objectively]

I would appreciate your assistance in resolving this matter. I believe a fair resolution would be [state your desired outcome].

I look forward to your prompt response.

Sincerely,
[Your Name]''';

      default:
        return '''Dear [Recipient],

[Write your letter content here]

Best regards,
[Your Name]''';
    }
  }

  void _onContentChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && _hasUnsavedChanges) {
          final navigator = Navigator.of(context);
          final shouldPop = await _showUnsavedChangesDialog();
          if (shouldPop && context.mounted) {
            navigator.pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.subcategory.name),
          actions: [
            if (_hasUnsavedChanges)
              TextButton(
                onPressed: _isLoading ? null : _saveLetter,
                child: _isLoading 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
              ),
            PopupMenuButton<String>(
              onSelected: _handleMenuSelection,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'ai_chatbot',
                  child: Row(
                    children: [
                      Icon(Icons.chat),
                      SizedBox(width: 8),
                      Text('AI Chatbot'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'ai_assistant',
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome),
                      SizedBox(width: 8),
                      Text('AI Assistant Panel'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'word_count',
                  child: Row(
                    children: [
                      Icon(Icons.format_list_numbered),
                      SizedBox(width: 8),
                      Text('Word Count'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'save_as_template',
                  child: Row(
                    children: [
                      Icon(Icons.bookmark_add),
                      SizedBox(width: 8),
                      Text('Save as Template'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'preview',
                  child: Row(
                    children: [
                      Icon(Icons.preview),
                      SizedBox(width: 8),
                      Text('Preview'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.file_download),
                      SizedBox(width: 8),
                      Text('Export PDF'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // Title input section
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _titleController,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Letter Title',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Editor section with simple toolbar
                Expanded(
                  flex: _showAIPanel ? 1 : 2,
                  child: Column(
                    children: [
                      // Simple formatting toolbar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                // Bold toggle
                                final selection = _controller.selection;
                                _controller.formatText(
                                  selection.start,
                                  selection.end - selection.start,
                                  Attribute.bold,
                                );
                              },
                              icon: const Icon(Icons.format_bold),
                              tooltip: 'Bold',
                            ),
                            IconButton(
                              onPressed: () {
                                // Italic toggle
                                final selection = _controller.selection;
                                _controller.formatText(
                                  selection.start,
                                  selection.end - selection.start,
                                  Attribute.italic,
                                );
                              },
                              icon: const Icon(Icons.format_italic),
                              tooltip: 'Italic',
                            ),
                            IconButton(
                              onPressed: () {
                                // Underline toggle
                                final selection = _controller.selection;
                                _controller.formatText(
                                  selection.start,
                                  selection.end - selection.start,
                                  Attribute.underline,
                                );
                              },
                              icon: const Icon(Icons.format_underlined),
                              tooltip: 'Underline',
                            ),
                            const VerticalDivider(),
                            IconButton(
                              onPressed: () {
                                // Bullet list
                                final selection = _controller.selection;
                                _controller.formatText(
                                  selection.start,
                                  selection.end - selection.start,
                                  Attribute.ul,
                                );
                              },
                              icon: const Icon(Icons.format_list_bulleted),
                              tooltip: 'Bullet List',
                            ),
                            IconButton(
                              onPressed: () {
                                // Numbered list
                                final selection = _controller.selection;
                                _controller.formatText(
                                  selection.start,
                                  selection.end - selection.start,
                                  Attribute.ol,
                                );
                              },
                              icon: const Icon(Icons.format_list_numbered),
                              tooltip: 'Numbered List',
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => _showWordCount(),
                              icon: const Icon(Icons.info_outline),
                              tooltip: 'Document Info',
                            ),
                          ],
                        ),
                      ),
                      
                      // Editor
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: QuillEditor.basic(
                            controller: _controller,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // AI Assistant Panel (when visible)
                if (_showAIPanel)
                  Expanded(
                    flex: 1,
                    child: AIAssistantPanel(
                      category: widget.category,
                      subcategory: widget.subcategory,
                      currentContent: _controller.document.toPlainText(),
                      onContentGenerated: _insertGeneratedContent,
                    ),
                  ),
              ],
            ),
            
            // AI Chatbot overlay (when visible)
            if (_showChatbot)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  child: AIChatbotWidget(
                    category: widget.category,
                    subcategory: widget.subcategory,
                    currentContent: _controller.document.toPlainText(),
                    onContentGenerated: _insertGeneratedContent,
                  ),
                ),
              ),
          ],
        ),
        
        // AI Assistant toggle button - now toggles chatbot by default
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _showChatbot = !_showChatbot;
              if (_showChatbot) _showAIPanel = false; // Close old panel
            });
          },
          backgroundColor: _showChatbot 
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            _showChatbot ? Icons.close : Icons.chat,
            color: _showChatbot 
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          tooltip: _showChatbot ? 'Close AI Chat' : 'Open AI Chat',
        ),
        // Move FloatingActionButton away from chatbot input when chatbot is visible
        floatingActionButtonLocation: _showChatbot 
          ? FloatingActionButtonLocation.endTop
          : FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Future<bool> _showUnsavedChangesDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. Do you want to save before leaving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(false);
              await _saveLetter();
              if (context.mounted) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _saveLetter() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title for your letter')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<LetterProvider>();
      final messenger = ScaffoldMessenger.of(context);
      
      final letter = Letter(
        id: widget.existingLetter?.id,
        title: _titleController.text.trim(),
        content: _controller.document.toPlainText(),
        categoryId: widget.category.id,
        subcategoryId: widget.subcategory.id,
        createdAt: widget.existingLetter?.createdAt,
      );
      
      await provider.saveLetter(letter);
      
      setState(() {
        _hasUnsavedChanges = false;
        _isLoading = false;
      });
      
      if (context.mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Letter saved successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving letter: $e')),
        );
      }
    }
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'ai_chatbot':
        setState(() {
          _showChatbot = !_showChatbot;
          if (_showChatbot) _showAIPanel = false; // Close old panel
        });
        break;
      case 'ai_assistant':
        setState(() {
          _showAIPanel = !_showAIPanel;
          if (_showAIPanel) _showChatbot = false; // Close chatbot
        });
        break;
      case 'word_count':
        _showWordCount();
        break;
      case 'save_as_template':
        _saveAsTemplate();
        break;
      case 'preview':
        _previewLetter();
        break;
      case 'export':
        _exportPDF();
        break;
    }
  }

  void _previewLetter() {
    final letter = Letter(
      id: widget.existingLetter?.id,
      title: _titleController.text.trim(),
      content: _controller.document.toPlainText(),
      categoryId: widget.category.id,
      subcategoryId: widget.subcategory.id,
      createdAt: widget.existingLetter?.createdAt,
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFPreviewScreen(letter: letter),
      ),
    );
  }

  void _exportPDF() {
    // Navigate to PDF preview instead of showing a placeholder
    _previewLetter();
  }

  void _insertGeneratedContent(String content) {
    // Insert AI-generated content into the editor at cursor position
    final index = _controller.selection.baseOffset;
    
    // If there's no selection, append to the end
    if (index < 0) {
      final endIndex = _controller.document.length;
      _controller.document.insert(endIndex, '\n\n$content');
      _controller.updateSelection(
        TextSelection.collapsed(offset: endIndex + content.length + 2),
        ChangeSource.local,
      );
    } else {
      // Insert at current cursor position
      _controller.document.insert(index, content);
      _controller.updateSelection(
        TextSelection.collapsed(offset: index + content.length),
        ChangeSource.local,
      );
    }
    
    // Mark as having unsaved changes
    _onContentChanged();
  }

  void _showWordCount() {
    final text = _controller.document.toPlainText();
    final wordCount = text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
    final charCount = text.length;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Document Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Words: $wordCount'),
            const SizedBox(height: 8),
            Text('Characters: $charCount'),
            const SizedBox(height: 8),
            Text('Characters (no spaces): ${text.replaceAll(' ', '').length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _saveAsTemplate() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title before saving as template')),
      );
      return;
    }

    final templateName = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: _titleController.text.trim());
        return AlertDialog(
          title: const Text('Save as Template'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter a name for this template:'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Template Name',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (templateName != null && templateName.isNotEmpty) {
      final template = Letter(
        title: templateName,
        content: _controller.document.toPlainText(),
        categoryId: widget.category.id,
        subcategoryId: widget.subcategory.id,
        isTemplate: true,
      );

      final provider = context.read<LetterProvider>();
      final messenger = ScaffoldMessenger.of(context);
      final success = await provider.saveLetter(template);
      if (success && mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Template saved successfully')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }
}
