import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/letter_category.dart';
import '../providers/letter_provider.dart';
import '../screens/settings/settings_screen.dart';

class AIChatbotWidget extends StatefulWidget {
  final LetterCategory category;
  final LetterSubcategory subcategory;
  final Function(String) onContentGenerated;
  final String currentContent;

  const AIChatbotWidget({
    super.key,
    required this.category,
    required this.subcategory,
    required this.onContentGenerated,
    required this.currentContent,
  });

  @override
  State<AIChatbotWidget> createState() => _AIChatbotWidgetState();
}

class _AIChatbotWidgetState extends State<AIChatbotWidget>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  late AnimationController _typingAnimationController;

  final List<String> _tones = [
    'professional',
    'formal',
    'friendly',
    'casual',
    'persuasive',
  ];
  String _selectedTone = 'professional';

  // Quick command suggestions based on letter type
  List<String> _quickCommands = [];

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _initializeQuickCommands();
    _addWelcomeMessage();
  }

  void _initializeQuickCommands() {
    switch (widget.subcategory.id) {
      case 'job_applications':
        _quickCommands = [
          'Write job letter',
          'Add skills',
          'Improve opening',
          'Better closing',
          'Make persuasive',
        ];
        break;
      case 'resignation':
        _quickCommands = [
          'Write resignation',
          'Add gratitude',
          'Plan transition',
          'Make professional',
          'Set notice period',
        ];
        break;
      case 'thank_you':
        _quickCommands = [
          'Write thank you',
          'Express gratitude',
          'Add personal touch',
          'Make warmer',
          'Better closing',
        ];
        break;
      case 'complaints':
        _quickCommands = [
          'Write complaint',
          'State problem',
          'Suggest solutions',
          'Be diplomatic',
          'Add evidence',
        ];
        break;
      default:
        _quickCommands = [
          'Write letter',
          'Improve content',
          'Make professional',
          'Fix structure',
          'Better language',
        ];
    }
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      text: "Hello! I'm your AI letter writing assistant. I'm here to help you create a perfect ${widget.subcategory.name.toLowerCase()}.\n\nYou can ask me to write content, improve existing text, or use the quick commands below. What would you like me to help you with?\n\n💡 Tip: Make sure you've configured your AI API key in Settings for the best experience!",
      isFromUser: false,
      timestamp: DateTime.now(),
    );
    setState(() {
      _messages.add(welcomeMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate appropriate height based on screen size
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final appBarHeight = kToolbarHeight;
    
    // Calculate available height (screen - app bar - safe areas)
    final availableHeight = screenHeight - safeAreaTop - safeAreaBottom - appBarHeight;
    
    // Use 60% of available height, but cap it at 500px and ensure minimum of 300px
    final chatbotHeight = (availableHeight * 0.6).clamp(300.0, 500.0);
    
    return Container(
      height: chatbotHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Chat messages
          Expanded(
            child: _buildChatArea(),
          ),
          
          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Letter Assistant',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  'Helping with ${widget.subcategory.name}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Tone selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButton<String>(
              value: _selectedTone,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, size: 18),
              style: Theme.of(context).textTheme.bodySmall,
              items: _tones.map((tone) {
                return DropdownMenuItem(
                  value: tone,
                  child: Text(tone.substring(0, 1).toUpperCase() + tone.substring(1)),
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
    );
  }

  Widget _buildChatArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Quick commands
          if (_messages.length <= 1) _buildQuickCommands(),
          
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCommands() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Commands:',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _quickCommands.map((command) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.45, // Max 45% of available width
                    ),
                    child: ActionChip(
                      label: Text(
                        command,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      onPressed: () => _sendQuickCommand(command),
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isFromUser;
    
    // Handle special settings button message
    if (message.isSpecial && message.text == "settings_button") {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16).copyWith(
                    bottomLeft: const Radius.circular(4),
                    bottomRight: const Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need help with AI configuration?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings, size: 16),
                      label: const Text('Open Settings'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: const Size(0, 32),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isUser
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (!isUser && message.hasActions) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            widget.onContentGenerated(message.text);
                            _addMessage(
                              'Content added to your letter!',
                              isFromUser: false,
                              hasActions: false,
                            );
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Use This'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: const Size(0, 32),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () {
                            _addMessage(
                              'I can help you generate different content. What would you like me to try instead?',
                              isFromUser: false,
                              hasActions: false,
                            );
                          },
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Regenerate'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: const Size(0, 32),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _typingAnimationController,
                  builder: (context, child) {
                    return Row(
                      children: List.generate(3, (index) {
                        final delay = index * 0.2;
                        final animation = Tween<double>(begin: 0.4, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _typingAnimationController,
                            curve: Interval(delay, delay + 0.3, curve: Curves.easeInOut),
                          ),
                        );
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: Opacity(
                            opacity: animation.value,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'AI is typing...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    final hasText = _messageController.text.trim().isNotEmpty;
    final canSend = hasText && !_isTyping;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), // Extra bottom padding
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Ask me to write, improve, or modify your letter...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, 
                  vertical: 12,
                ),
              ),
              onSubmitted: _isTyping ? null : (_) => _sendMessage(),
              onChanged: (text) {
                setState(() {}); // Rebuild to update send button color
              },
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: canSend 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
              shape: BoxShape.circle,
              boxShadow: canSend ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: IconButton(
              onPressed: canSend ? _sendMessage : null,
              icon: _isTyping 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Icon(
                    Icons.send_rounded,
                    color: canSend 
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.outline,
                    size: 20,
                  ),
              tooltip: canSend ? 'Send message' : 'Type a message to send',
              splashRadius: 24,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isTyping) return;

    _addMessage(message, isFromUser: true);
    _messageController.clear();
    _generateAIResponse(message);
  }

  void _sendQuickCommand(String command) {
    // Expand short command to full prompt for better AI understanding
    final fullPrompt = _expandCommand(command);
    _addMessage(command, isFromUser: true);
    _generateAIResponse(fullPrompt);
  }

  String _expandCommand(String shortCommand) {
    // Create context-aware expansion based on current subcategory
    final categoryId = widget.subcategory.id;
    
    switch (shortCommand) {
      case 'Write job letter':
        return 'Write a complete job application letter';
      case 'Add skills':
        return 'Add professional skills section';
      case 'Improve opening':
        return 'Improve opening paragraph';
      case 'Better closing':
        return categoryId == 'thank_you' ? 'Create heartfelt closing' : 'Create compelling closing';
      case 'Make persuasive':
        return 'Make it more persuasive';
        
      case 'Write resignation':
        return 'Write a resignation letter';
      case 'Add gratitude':
        return 'Add gratitude and appreciation';
      case 'Plan transition':
        return 'Include transition planning';
      case 'Make professional':
        return 'Make it more professional';
      case 'Set notice period':
        return 'Add proper notice period';
        
      case 'Write thank you':
        return 'Write a thank you letter';
      case 'Express gratitude':
        return 'Express deep gratitude';
      case 'Add personal touch':
        return 'Add personal touch';
      case 'Make warmer':
        return 'Make it warmer';
        
      case 'Write complaint':
        return 'Write a complaint letter';
      case 'State problem':
        return 'State problem clearly';
      case 'Suggest solutions':
        return 'Suggest solutions';
      case 'Be diplomatic':
        return 'Make it diplomatic';
      case 'Add evidence':
        return 'Add supporting evidence';
        
      case 'Write letter':
        return 'Write a complete letter';
      case 'Improve content':
        return 'Improve the content';
      case 'Fix structure':
        return 'Add proper structure';
      case 'Better language':
        return 'Enhance the language';
        
      default:
        return shortCommand;
    }
  }

  void _addMessage(String text, {required bool isFromUser, bool hasActions = true}) {
    final message = ChatMessage(
      text: text,
      isFromUser: isFromUser,
      timestamp: DateTime.now(),
      hasActions: hasActions && !isFromUser,
    );

    setState(() {
      _messages.add(message);
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _generateAIResponse(String userMessage) async {
    setState(() {
      _isTyping = true;
    });

    try {
      // Scroll to show typing indicator
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

      final provider = context.read<LetterProvider>();
      final content = await provider.generateContent(
        category: widget.category.name,
        subcategory: widget.subcategory.name,
        prompt: userMessage,
        tone: _selectedTone,
      );

      if (content != null && content.isNotEmpty) {
        _addMessage(content, isFromUser: false, hasActions: true);
      } else {
        _addMessage(
          "I apologize, but I'm having trouble generating content right now. Please check your AI settings in the Settings screen or try again later.",
          isFromUser: false,
          hasActions: false,
        );
      }
    } catch (e) {
      String errorMessage;
      bool showSettingsButton = false;
      
      if (e.toString().contains('API key not configured')) {
        errorMessage = "Please configure your AI API key in Settings to use AI features. I'll show you a template instead.";
        showSettingsButton = true;
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage = "Network error: Please check your internet connection and try again.";
      } else {
        errorMessage = "Sorry, I encountered an error: ${e.toString()}. Please try again or check your AI configuration in Settings.";
        showSettingsButton = true;
      }
      
      _addMessage(
        errorMessage,
        isFromUser: false,
        hasActions: false,
      );
      
      // Add a settings button for configuration errors
      if (showSettingsButton) {
        _addSettingsButton();
      }
    } finally {
      setState(() {
        _isTyping = false;
      });
    }
  }

  void _addSettingsButton() {
    // Add a special message with a settings button
    setState(() {
      _messages.add(ChatMessage(
        text: "settings_button",
        isFromUser: false,
        timestamp: DateTime.now(),
        hasActions: false,
        isSpecial: true,
      ));
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isFromUser;
  final DateTime timestamp;
  final bool hasActions;
  final bool isSpecial;

  ChatMessage({
    required this.text,
    required this.isFromUser,
    required this.timestamp,
    this.hasActions = false,
    this.isSpecial = false,
  });
}
