import 'dart:math';
import '../models/eco_tip.dart';
import '../models/recycling_item.dart';
import '../models/green_product.dart';
import '../repositories/tips_repository.dart';
import '../repositories/recycling_repository.dart';
import '../repositories/products_repository.dart';

enum AiResponseType { greeting, tip, recycling, product, challenge, unknown }

class AiMessage {
  final String id;
  final bool isUser;
  final String text;
  final AiResponseType responseType;
  final List<EcoTip> tips;
  final List<RecyclingItem> recyclingItems;
  final List<GreenProduct> products;
  final DateTime timestamp;

  const AiMessage({
    required this.id,
    required this.isUser,
    required this.text,
    this.responseType = AiResponseType.unknown,
    this.tips = const [],
    this.recyclingItems = const [],
    this.products = const [],
    required this.timestamp,
  });

  factory AiMessage.user(String text) => AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        isUser: true,
        text: text,
        timestamp: DateTime.now(),
      );

  factory AiMessage.bot({
    required String text,
    AiResponseType type = AiResponseType.unknown,
    List<EcoTip> tips = const [],
    List<RecyclingItem> recyclingItems = const [],
    List<GreenProduct> products = const [],
  }) =>
      AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        isUser: false,
        text: text,
        responseType: type,
        tips: tips,
        recyclingItems: recyclingItems,
        products: products,
        timestamp: DateTime.now(),
      );
}

class AiService {
  final TipsRepository _tipsRepo = TipsRepository();
  final RecyclingRepository _recyclingRepo = RecyclingRepository();
  final ProductsRepository _productsRepo = ProductsRepository();

  List<EcoTip>? _cachedTips;
  List<RecyclingItem>? _cachedRecycling;
  List<GreenProduct>? _cachedProducts;

  // ── Keyword → Intent Maps ────────────────────────────────────────────────

  static const List<String> _recycleKeywords = [
    'recycl', 'dispose', 'bin', 'throw', 'waste', 'trash', 'rubbish',
    'ewaste', 'e-waste', 'plastic', 'glass', 'paper', 'metal', 'alumin',
    'cardboard', 'bottle', 'can', 'tin', 'organic', 'compost', 'battery',
    'batteries', 'smartphone', 'laptop', 'phone', 'computer', 'cartridge',
    'printer', 'styrofoam', 'polystyrene',
  ];

  static const List<String> _energyKeywords = [
    'energy', 'electric', 'electricity', 'power', 'bulb', 'led', 'light',
    'solar', 'thermostat', 'standby', 'applianc', 'plug', 'unplug',
    'watt', 'heat', 'cool', 'air condition',
  ];

  static const List<String> _waterKeywords = [
    'water', 'shower', 'tap', 'leak', 'drip', 'rain', 'rainwater',
    'dishwasher', 'washing', 'conserv', 'litre', 'liter',
  ];

  static const List<String> _shoppingKeywords = [
    'shop', 'buy', 'purchas', 'product', 'eco product', 'green product',
    'reusabl', 'sustainable', 'certif', 'bamboo', 'packaging', 'brand',
    'zero waste',
  ];

  static const List<String> _challengeKeywords = [
    'challeng', 'task', 'goal', 'earn', 'point', 'score', 'streak',
    'daily', 'weekly', 'meatless', 'cycle', 'walk',
  ];

  static const List<String> _tipKeywords = [
    'tip', 'advice', 'suggest', 'help', 'how', 'what', 'guide',
    'recommend', 'idea', 'hack',
  ];

  static const List<String> _greetings = [
    'hello', 'hi', 'hey', 'greet', 'hola', 'salaam',
    'good morning', 'good evening',
  ];

  // ── Public API ───────────────────────────────────────────────────────────

  Future<void> warmUp() async {
    _cachedTips ??= await _tipsRepo.loadAll();
    _cachedRecycling ??= await _recyclingRepo.loadAll();
    _cachedProducts ??= await _productsRepo.loadAll();
  }

  Future<AiMessage> processQuery(String query, {String? preferredArea}) async {
    await warmUp();
    final q = query.toLowerCase().trim();

    if (q.isEmpty) return _greetingResponse(preferredArea);

    // Intent Classification
    if (_matchesAny(q, _greetings)) return _greetingResponse(preferredArea);

    final isRecycle = _matchesAny(q, _recycleKeywords);
    final isEnergy = _matchesAny(q, _energyKeywords);
    final isWater = _matchesAny(q, _waterKeywords);
    final isShopping = _matchesAny(q, _shoppingKeywords);
    final isChallenge = _matchesAny(q, _challengeKeywords);
    final isTip = _matchesAny(q, _tipKeywords);

    if (isRecycle) {
      final items = _searchRecycling(q);
      if (items.isNotEmpty) {
        return AiMessage.bot(
          text: '♻️ Here\'s what I found in the Recycling Guide. '
              'Remember to clean items before recycling!',
          type: AiResponseType.recycling,
          recyclingItems: items.take(3).toList(),
        );
      }
    }

    if (isEnergy) {
      final tips = _filterTips('Energy', q);
      return AiMessage.bot(
        text: '⚡ Here are energy-saving tips to reduce your '
            'electricity bill and carbon footprint:',
        type: AiResponseType.tip,
        tips: tips.take(3).toList(),
      );
    }

    if (isWater) {
      final tips = _filterTips('Water', q);
      return AiMessage.bot(
        text: '💧 Water conservation matters! Here are my top tips '
            'to help you save water every day:',
        type: AiResponseType.tip,
        tips: tips.take(3).toList(),
      );
    }

    if (isShopping) {
      final prods = _searchProducts(q);
      if (prods.isNotEmpty) {
        return AiMessage.bot(
          text: '🛍️ Here are eco-friendly products that match your query:',
          type: AiResponseType.product,
          products: prods.take(3).toList(),
        );
      }
      final tips = _filterTips('Sustainable Shopping', q);
      return AiMessage.bot(
        text: '🛍️ Here are some sustainable shopping tips:',
        type: AiResponseType.tip,
        tips: tips.take(3).toList(),
      );
    }

    if (isChallenge) return _challengeResponse();

    if (isTip) {
      final tips = (preferredArea != null && preferredArea.isNotEmpty)
          ? _filterTips(preferredArea, '')
          : _randomTips(3);
      final selectedTips = tips.isNotEmpty ? tips.take(3).toList() : _randomTips(3);
      return AiMessage.bot(
        text: '🌿 Here are some eco tips I recommend for you today:',
        type: AiResponseType.tip,
        tips: selectedTips,
      );
    }

    final anyTips = _fullTextTips(q);
    if (anyTips.isNotEmpty) {
      return AiMessage.bot(
        text: '💡 I found some relevant eco tips for your question:',
        type: AiResponseType.tip,
        tips: anyTips.take(3).toList(),
      );
    }

    final anyItems = _searchRecycling(q);
    if (anyItems.isNotEmpty) {
      return AiMessage.bot(
        text: '♻️ Your query matched these items in the Recycling Guide:',
        type: AiResponseType.recycling,
        recyclingItems: anyItems.take(3).toList(),
      );
    }

    return _unknownResponse(preferredArea);
  }

  // ── Private Helpers ──────────────────────────────────────────────────────

  bool _matchesAny(String query, List<String> keywords) =>
      keywords.any((kw) => query.contains(kw));

  List<EcoTip> _filterTips(String category, String query) {
    final all = _cachedTips ?? [];
    final byCategory = all.where((t) => t.category == category).toList();
    final words = query.split(' ').where((w) => w.length > 3).toList();
    if (words.isNotEmpty) {
      final refined = byCategory
          .where((t) =>
              words.any((w) =>
                  t.title.toLowerCase().contains(w) ||
                  t.description.toLowerCase().contains(w)))
          .toList();
      return refined.isNotEmpty ? refined : byCategory;
    }
    return byCategory;
  }

  List<EcoTip> _fullTextTips(String query) {
    final all = _cachedTips ?? [];
    final words = query.split(' ').where((w) => w.length > 3).toList();
    return all
        .where((t) =>
            words.any((w) =>
                t.title.toLowerCase().contains(w) ||
                t.description.toLowerCase().contains(w)))
        .toList();
  }

  List<RecyclingItem> _searchRecycling(String query) {
    final all = _cachedRecycling ?? [];
    final words = query.split(' ').where((w) => w.length > 2).toList();
    return all
        .where((item) =>
            words.any((w) =>
                item.name.toLowerCase().contains(w) ||
                item.category.toLowerCase().contains(w) ||
                item.disposalMethod.toLowerCase().contains(w)))
        .toList();
  }

  List<GreenProduct> _searchProducts(String query) {
    final all = _cachedProducts ?? [];
    final words = query.split(' ').where((w) => w.length > 2).toList();
    return all
        .where((p) =>
            words.any((w) =>
                p.name.toLowerCase().contains(w) ||
                p.category.toLowerCase().contains(w) ||
                p.description.toLowerCase().contains(w)))
        .toList();
  }

  List<EcoTip> _randomTips(int count) {
    final all = List<EcoTip>.from(_cachedTips ?? []);
    all.shuffle(Random());
    return all.take(count).toList();
  }

  AiMessage _greetingResponse(String? preferredArea) {
    if (preferredArea != null && preferredArea.isNotEmpty) {
      final tips = _filterTips(preferredArea, '');
      final selectedTips = tips.isNotEmpty ? tips.take(2).toList() : _randomTips(2);
      return AiMessage.bot(
        text: '👋 Hello! I see your focus is on $preferredArea. Here are some tailored tips for you, but feel free to ask me anything else!',
        type: AiResponseType.greeting,
        tips: selectedTips,
      );
    }
    return AiMessage.bot(
      text: '👋 Hello! I\'m your GreenLife Eco AI Assistant. I can help with:\n\n'
          '• ♻️ Recycling & disposal guidance\n'
          '• ⚡ Energy & water saving tips\n'
          '• 🛍️ Eco-friendly product recommendations\n'
          '• 🏆 Daily & weekly eco challenge info\n\n'
          'Just ask me anything or tap a suggestion below!',
      type: AiResponseType.greeting,
    );
  }

  AiMessage _challengeResponse() => AiMessage.bot(
        text: '🏆 Eco Challenges help you build green habits and earn points!\n\n'
            '• ✅ Complete Daily Challenges (10–20 pts)\n'
            '• 📅 Complete Weekly Challenges (50–75 pts)\n'
            '• 🌱 Track your Eco Score on the Challenges tab\n\n'
            'Head to the Challenges tab to mark your progress!',
        type: AiResponseType.challenge,
      );

  AiMessage _unknownResponse(String? preferredArea) {
    final tips = (preferredArea != null && preferredArea.isNotEmpty)
        ? _filterTips(preferredArea, '')
        : _randomTips(2);
    final selectedTips = tips.isNotEmpty ? tips.take(2).toList() : _randomTips(2);
    return AiMessage.bot(
      text: '🤔 I\'m not sure I understood that, but here are some '
          'eco tips based on your focus. Try asking about recycling, '
          'energy, water, products, or challenges!',
      type: AiResponseType.tip,
      tips: selectedTips,
    );
  }
}
