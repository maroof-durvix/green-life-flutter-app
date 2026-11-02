import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../core/theme/app_colors.dart';
import '../services/ai_service.dart';
import '../widgets/eco_tip_card.dart';
import '../widgets/recycling_item_tile.dart';
import '../widgets/product_card.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final AiService _aiService = AiService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<AiMessage> _messages = [];
  bool _isTyping = false;

  final List<String> _quickPrompts = [
    'How to dispose e-waste?',
    'Energy saving tips',
    'Eco-friendly products',
    'What are eco challenges?',
  ];

  @override
  void initState() {
    super.initState();
    _loadGreeting();
  }

  Future<void> _loadGreeting() async {
    setState(() => _isTyping = true);
    final preferredArea = context.read<AppController>().preferredArea;
    final greeting = await _aiService.processQuery('', preferredArea: preferredArea);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _messages.add(greeting);
        _isTyping = false;
      });
    }
  }

  Future<void> _handleSubmitted(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    _textController.clear();
    setState(() {
      _messages.add(AiMessage.user(query));
      _isTyping = true;
    });
    _scrollToBottom();

    final preferredArea = context.read<AppController>().preferredArea;
    final response = await _aiService.processQuery(query, preferredArea: preferredArea);
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _messages.add(response);
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Eco Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _messages.clear());
              _loadGreeting();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          
          if (_messages.length <= 1)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _quickPrompts.length,
                separatorBuilder: (context, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ActionChip(
                    label: Text(_quickPrompts[index]),
                    onPressed: () => _handleSubmitted(_quickPrompts[index]),
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.cardBorder),
                  );
                },
              ),
            ),
            
          Container(
            padding: const EdgeInsets.all(16).copyWith(bottom: 24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Ask me about recycling, tips, products...',
                      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: _handleSubmitted,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppColors.background),
                    onPressed: () => _handleSubmitted(_textController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20).copyWith(bottomLeft: Radius.zero),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            SizedBox(width: 12),
            Text('Thinking...', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(AiMessage message) {
    final isUser = message.isUser;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 16,
                  child: Icon(Icons.smart_toy, size: 18, color: AppColors.background),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(20).copyWith(
                      bottomRight: isUser ? Radius.zero : const Radius.circular(20),
                      bottomLeft: !isUser ? Radius.zero : const Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? AppColors.background : AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          if (!isUser) _buildRichContent(message),
        ],
      ),
    );
  }

  Widget _buildRichContent(AiMessage message) {
    if (message.tips.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 12, left: 40),
        child: Column(
          children: message.tips.map((tip) => EcoTipCard(tip: tip)).toList(),
        ),
      );
    }
    
    if (message.recyclingItems.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 12, left: 40),
        child: Column(
          children: message.recyclingItems.map((item) => RecyclingItemTile(item: item)).toList(),
        ),
      );
    }
    
    if (message.products.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 12, left: 40),
        child: SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: message.products.length,
            itemBuilder: (context, index) {
              return ProductCard(product: message.products[index], compact: true);
            },
          ),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
}
