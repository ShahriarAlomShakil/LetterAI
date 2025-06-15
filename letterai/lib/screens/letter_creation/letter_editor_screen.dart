import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import '../../models/letter.dart';
import '../../models/letter_category.dart';
import '../../providers/letter_provider.dart';
import '../../constants/app_theme.dart';
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
        return 'New Letter';
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
    final screenSize = MediaQuery.of(context).size;
    final isDark = AppTheme.isDarkMode(context);
    final theme = Theme.of(context);
    
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
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // Theme-aware animated background
            Container(
              height: screenSize.height,
              width: screenSize.width,
              decoration: BoxDecoration(
                gradient: AppTheme.getBackgroundGradient(isDark),
              ),
            ),
            
            // Floating orbs for depth
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.getOrbColor(isDark),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            Positioned(
              bottom: -80,
              left: -60,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.getOrbColor(isDark),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            // Blur overlay
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark 
                    ? Colors.black.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Modern App Bar with glassmorphism - Ultra compact
                  Container(
                    margin: const EdgeInsets.fromLTRB(10, 6, 10, 4),
                    decoration: BoxDecoration(
                      gradient: AppTheme.getGlassmorphismGradient(isDark),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.getGlassBorderColor(isDark),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: AppTheme.getGlassmorphismGradient(isDark),
                          ),
                          child: Row(
                            children: [
                              // Back button - Ultra compact
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppTheme.getGlassBorderColor(isDark),
                                    width: 1,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => Navigator.of(context).pop(),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.arrow_back_ios_new,
                                        color: theme.colorScheme.onSurface,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 10),
                              
                              // Title section - Ultra compact
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.subcategory.name,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppTheme.getGlassBorderColor(isDark),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        widget.category.name,
                                        style: TextStyle(
                                          color: theme.colorScheme.onPrimaryContainer,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Action buttons
                              Row(
                                children: [
                                  // Save button - Ultra compact
                                  if (_hasUnsavedChanges)
                                    Container(
                                      margin: const EdgeInsets.only(right: 4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: _isLoading ? null : _saveLetter,
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                            child: _isLoading 
                                              ? const SizedBox(
                                                  width: 12,
                                                  height: 12,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                      Colors.white,
                                                    ),
                                                  ),
                                                )
                                              : Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.save,
                                                      color: Colors.white,
                                                      size: 12,
                                                    ),
                                                    const SizedBox(width: 3),
                                                    const Text(
                                                      'Save',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  
                                  // Menu button - Ultra compact
                                  Container(
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppTheme.getGlassBorderColor(isDark),
                                        width: 1,
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: PopupMenuButton<String>(
                                        onSelected: _handleMenuSelection,
                                        offset: const Offset(0, 36),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        color: theme.colorScheme.surface,
                                        elevation: 16,
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.more_vert,
                                            color: theme.colorScheme.onSurface,
                                            size: 14,
                                          ),
                                        ),
                                        itemBuilder: (context) => [
                                          _buildMenuItem(Icons.chat, 'AI Chatbot', 'ai_chatbot', isDark),
                                          _buildMenuItem(Icons.auto_awesome, 'AI Assistant Panel', 'ai_assistant', isDark),
                                          _buildMenuItem(Icons.format_list_numbered, 'Word Count', 'word_count', isDark),
                                          _buildMenuItem(Icons.bookmark_add, 'Save as Template', 'save_as_template', isDark),
                                          const PopupMenuDivider(),
                                          _buildMenuItem(Icons.preview, 'Preview', 'preview', isDark),
                                          _buildMenuItem(Icons.file_download, 'Export PDF', 'export', isDark),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Main editor content - Maximized space with minimal margins
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(10, 2, 10, 6),
                      decoration: BoxDecoration(
                        gradient: AppTheme.getGlassmorphismGradient(isDark),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppTheme.getGlassBorderColor(isDark),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Column(
                            children: [
                              // Title input section - Ultra compact
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppTheme.getGlassBorderColor(isDark),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: TextField(
                                  controller: _titleController,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Letter title...',
                                    hintStyle: TextStyle(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                ),
                              ),
                              
                              // Modern formatting toolbar - More compact
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface.withValues(alpha: 0.3),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppTheme.getGlassBorderColor(isDark),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _buildToolbarButton(Icons.format_bold, 'Bold', () {
                                      final selection = _controller.selection;
                                      _controller.formatText(
                                        selection.start,
                                        selection.end - selection.start,
                                        Attribute.bold,
                                      );
                                    }, isDark),
                                    const SizedBox(width: 8),
                                    _buildToolbarButton(Icons.format_italic, 'Italic', () {
                                      final selection = _controller.selection;
                                      _controller.formatText(
                                        selection.start,
                                        selection.end - selection.start,
                                        Attribute.italic,
                                      );
                                    }, isDark),
                                    const SizedBox(width: 8),
                                    _buildToolbarButton(Icons.format_underlined, 'Underline', () {
                                      final selection = _controller.selection;
                                      _controller.formatText(
                                        selection.start,
                                        selection.end - selection.start,
                                        Attribute.underline,
                                      );
                                    }, isDark),
                                    
                                    Container(
                                      width: 1,
                                      height: 20,
                                      margin: const EdgeInsets.symmetric(horizontal: 10),
                                      color: AppTheme.getGlassBorderColor(isDark),
                                    ),
                                    
                                    _buildToolbarButton(Icons.format_list_bulleted, 'Bullet List', () {
                                      final selection = _controller.selection;
                                      _controller.formatText(
                                        selection.start,
                                        selection.end - selection.start,
                                        Attribute.ul,
                                      );
                                    }, isDark),
                                    const SizedBox(width: 8),
                                    _buildToolbarButton(Icons.format_list_numbered, 'Numbered List', () {
                                      final selection = _controller.selection;
                                      _controller.formatText(
                                        selection.start,
                                        selection.end - selection.start,
                                        Attribute.ol,
                                      );
                                    }, isDark),
                                    
                                    const Spacer(),
                                    
                                    _buildToolbarButton(Icons.info_outline, 'Document Info', () {
                                      _showWordCount();
                                    }, isDark),
                                  ],
                                ),
                              ),
                              
                              // Editor - Maximized space
                              Expanded(
                                flex: _showAIPanel ? 1 : 4, // Increased flex to give more space
                                child: Container(
                                  padding: const EdgeInsets.all(16), // Reduced padding
                                  child: QuillEditor.basic(
                                    controller: _controller,
                                  ),
                                ),
                              ),
                              
                              // AI Assistant Panel (when visible) - Reduced height
                              if (_showAIPanel)
                                Container(
                                  height: 250, // Reduced from 300 to 250
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: AppTheme.getGlassBorderColor(isDark),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: AIAssistantPanel(
                                    category: widget.category,
                                    subcategory: widget.subcategory,
                                    currentContent: _controller.document.toPlainText(),
                                    onContentGenerated: _insertGeneratedContent,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
                    onClose: () {
                      setState(() {
                        _showChatbot = false;
                      });
                    },
                  ),
                ),
              ),
          ],
        ),
        
        // Ultra modern compact AI Assistant floating button (hidden when chatbot is open)
        floatingActionButton: _showChatbot ? null : Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _showChatbot = true;
                  _showAIPanel = false;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Future<bool> _showUnsavedChangesDialog() async {
    final isDark = AppTheme.isDarkMode(context);
    final theme = Theme.of(context);
    
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppTheme.getGlassmorphismGradient(isDark),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.getGlassBorderColor(isDark),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                blurRadius: 30,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.save_outlined,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Title
                  Text(
                    'Unsaved Changes',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Content
                  Text(
                    'You have unsaved changes. Do you want to save before leaving?',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  Row(
                    children: [
                      // Discard button
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.getGlassBorderColor(isDark),
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.of(context).pop(true),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                alignment: Alignment.center,
                                child: Text(
                                  'Discard',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Save button
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                Navigator.of(context).pop(false);
                                await _saveLetter();
                                if (context.mounted) {
                                  Navigator.of(context).pop(true);
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Cancel button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.getGlassBorderColor(isDark),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(false),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          alignment: Alignment.center,
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ) ?? false;
  }

  Future<void> _saveLetter() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a title for your letter'),
          backgroundColor: Theme.of(context).colorScheme.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
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
          SnackBar(
            content: const Text('Letter saved successfully'),
            backgroundColor: Theme.of(context).colorScheme.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving letter: $e'),
            backgroundColor: Theme.of(context).colorScheme.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
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
    // Replace all content in the editor with the AI-generated content
    _controller.document = Document()..insert(0, content);
    _controller.updateSelection(
      TextSelection.collapsed(offset: content.length),
      ChangeSource.local,
    );
    
    // Mark as having unsaved changes
    _onContentChanged();
  }

  void _showWordCount() {
    final theme = Theme.of(context);
    final text = _controller.document.toPlainText();
    final wordCount = text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
    final charCount = text.length;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.analytics, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              'Document Statistics',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSimpleStatItem('Words', wordCount.toString(), Icons.format_list_bulleted),
            const SizedBox(height: 12),
            _buildSimpleStatItem('Characters', charCount.toString(), Icons.text_fields),
            const SizedBox(height: 12),
            _buildSimpleStatItem('Characters (no spaces)', text.replaceAll(' ', '').length.toString(), Icons.format_size),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStatItem(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _saveAsTemplate() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a title before saving as template'),
          backgroundColor: Theme.of(context).colorScheme.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final templateName = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: _titleController.text.trim());
        final theme = Theme.of(context);
        
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.bookmark_add, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Save as Template',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter a name for this template:',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Template Name',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
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
          SnackBar(
            content: const Text('Template saved successfully'),
            backgroundColor: Theme.of(context).colorScheme.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  // Helper method to build popup menu items with modern styling
  PopupMenuItem<String> _buildMenuItem(IconData icon, String text, String value, bool isDark) {
    final theme = Theme.of(context);
    
    return PopupMenuItem(
      value: value,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.getGlassBorderColor(isDark),
                  width: 0.5,
                ),
              ),
              child: Icon(
                icon,
                size: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build modern toolbar buttons - More compact
  Widget _buildToolbarButton(IconData icon, String tooltip, VoidCallback onPressed, bool isDark) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.getGlassBorderColor(isDark),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 14,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }
}
