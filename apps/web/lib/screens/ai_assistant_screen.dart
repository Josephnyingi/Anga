import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../services/ai_assistant_service.dart';

/// 🤖 **AI Assistant Screen for Web**
/// 
/// This screen provides AI-powered farming assistance.
class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _suggestionsScrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  final List<String> _suggestions = const [
    'Best time to plant maize?',
    '7-day weather for Machakos',
    'How to improve soil fertility?',
    'Pest control for beans',
  ];

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _suggestionsScrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    _messages.add({
      'text': 'Hello! I\'m your AI farming assistant. How can I help you today?',
      'isUser': false,
      'timestamp': DateTime.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Suggestions (quick actions). Scrollbar makes it visible that
          // this row scrolls - it was previously hard-clipped at the
          // viewport edge with no indication there was more to see.
          Scrollbar(
            controller: _suggestionsScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _suggestionsScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 4),
              child: Row(
                children: _suggestions.map((s) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _SuggestionChip(
                        label: s,
                        enabled: !_isLoading,
                        onTap: () {
                          _messageController.text = s;
                          _sendMessage();
                        },
                      ),
                    )).toList(),
              ),
            ),
          ),
          // Header
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.assistant,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Farming Assistant',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Online',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Typing indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 6),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.assistant, size: 14, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text('Typing...'),
                  ),
                ],
              ),
            ),

          // Input Area - SIMPLE AND CLEAR
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Text Input
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type your farming question here...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      maxLines: null,
                      onChanged: (value) {
                        setState(() {}); // Update button state
                      },
                      onSubmitted: _isLoading ? null : (value) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                // BIG SEND BUTTON
                Container(
                  height: 50,
                  width: 120,
                  decoration: BoxDecoration(
                    color: _messageController.text.trim().isNotEmpty && !_isLoading
                        ? Theme.of(context).primaryColor
                        : Colors.grey[400],
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: _isLoading || _messageController.text.trim().isEmpty 
                          ? null 
                          : _sendMessage,
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isLoading ? 'Sending...' : 'SEND',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
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
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;
    final text = message['text'] as String;
    final timestamp = message['timestamp'] as DateTime;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(
                Icons.assistant,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).primaryColor
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI replies come back with **bold**/* bullet* markdown
                  // from the model - render it properly instead of showing
                  // the raw asterisks. User messages are plain text as typed.
                  if (isUser)
                    Text(text, style: const TextStyle(color: Colors.white))
                  else
                    MarkdownBody(
                      data: text,
                      shrinkWrap: true,
                      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                        p: const TextStyle(color: Colors.black87),
                        listBullet: const TextStyle(color: Colors.black87),
                        strong: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isUser
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: const Icon(
                Icons.person,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    print('AI Assistant: Send message called with text: "$text"');
    print('AI Assistant: Is loading: $_isLoading');
    
    if (text.isEmpty || _isLoading) {
      print('AI Assistant: Skipping send - text empty or loading');
      return;
    }

    print('AI Assistant: Adding user message to chat');
    // Add user message
    setState(() {
      _messages.add({
        'text': text,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
      _isLoading = true;
    });

    _messageController.clear();

    try {
      print('AI Assistant: Calling AI service with prompt: "$text"');
      // Call backend AI assistant
      final answer = await AIAssistantService.askAssistant(prompt: text);
      print('AI Assistant: Received answer: "$answer"');
      
      setState(() {
        _messages.add({
          'text': answer,
          'isUser': false,
          'timestamp': DateTime.now(),
        });
      });
    } catch (e) {
      print('AI Assistant: Error occurred: $e');
      setState(() {
        _messages.add({
          'text': '⚠️ Error: ${e.toString()}',
          'isUser': false,
          'timestamp': DateTime.now(),
        });
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

/// A tap-to-send suggestion pill. Deliberately not built on Flutter's Chip
/// family (ActionChip/ChoiceChip etc. share a base implementation that
/// exposes checkbox-like semantics to screen readers even for chips with no
/// selection state) - Material + InkWell gives correct "button" semantics.
class _SuggestionChip extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Material(
      color: primaryColor.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            label,
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
