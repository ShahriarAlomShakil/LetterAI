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
  final VoidCallback? onClose;

  const AIChatbotWidget({
    super.key,
    required this.category,
    required this.subcategory,
    required this.onContentGenerated,
    required this.currentContent,
    this.onClose,
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

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      text: "Hello! I'm your AI letter writing assistant. I'm here to help you create a perfect ${widget.subcategory.name.toLowerCase()}.\n\nYou can ask me to write content, improve existing text, or tell me what you need help with. What would you like me to help you with?\n\n💡 Tip: Make sure you've configured your AI API key in Settings for the best experience!",
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
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // Chat messages
              Expanded(
                child: _buildChatArea(),
              ),
              
              // Input area
              _buildInputArea(),
            ],
          ),
          
          // Floating close button in top-right corner
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: widget.onClose ?? () {
                  // Fallback: try to pop if no callback provided
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 20,
                ),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        children: [
          // Tone selector at the top
          Row(
            children: [
              Icon(
                Icons.palette,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 8),
              Text(
                'Tone:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButton<String>(
                  value: _selectedTone,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, size: 16),
                  style: Theme.of(context).textTheme.bodySmall,
                  items: _tones.map((tone) {
                    return DropdownMenuItem(
                      value: tone,
                      child: Text(
                        tone.substring(0, 1).toUpperCase() + tone.substring(1),
                        style: const TextStyle(fontSize: 12),
                      ),
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
          const SizedBox(height: 12),
          
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
                              'Content replaced in your letter!',
                              isFromUser: false,
                              hasActions: false,
                            );
                          },
                          icon: const Icon(Icons.swap_horiz, size: 16),
                          label: const Text('Replace'),
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
