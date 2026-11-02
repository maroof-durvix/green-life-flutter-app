import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../core/theme/app_colors.dart';
import '../models/eco_tip.dart';
import '../models/green_product.dart';
import '../models/challenge.dart';
import '../repositories/tips_repository.dart';
import '../repositories/products_repository.dart';
import '../widgets/section_header.dart';
import '../widgets/eco_tip_card.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<EcoTip> _featuredTips = [];
  List<GreenProduct> _featuredProducts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final tips = await TipsRepository().loadAll();
    final products = await ProductsRepository().loadAll();
    if (mounted) {
      setState(() {
        _featuredTips = tips.take(5).toList();
        _featuredProducts = products.take(4).toList();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeBanner(context, controller),
            _buildActiveChallengeCard(context, controller),
            SectionHeader(
              title: 'Eco Tips', 
              onSeeAll: () => controller.setTabIndex(1), // Navigates to Tips Tab
            ),
            _buildFeaturedTips(),
            SectionHeader(
              title: 'Green Products', 
              onSeeAll: () => controller.setTabIndex(3), // Navigates to Products Tab
            ),
            _buildFeaturedProducts(context),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner(
      BuildContext context, AppController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.secondary.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.isUserSetupComplete
                      ? 'Hello, ${controller.userName}! 🌍'
                      : 'Welcome to GreenLife! 🌍',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  controller.isUserSetupComplete
                      ? 'Focus: ${controller.preferredArea}'
                      : 'Start your eco journey today.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                // Score row
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${controller.ecoScore} pts earned',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.check_circle_outline,
                        color: AppColors.textSecondary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${controller.completedCount}/${controller.totalChallenges}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco, color: AppColors.primary, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveChallengeCard(
      BuildContext context, AppController controller) {
    // Show first incomplete challenge as "Today's Focus"
    final Challenge? activeChallenge = controller.challenges
        .where((c) => c.type == 'daily' && !c.isCompleted)
        .cast<Challenge?>()
        .firstOrNull;

    if (activeChallenge == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.4), width: 1),
        ),
        child: const Row(
          children: [
            Icon(Icons.celebration, color: AppColors.primary, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'All daily challenges complete! Great work 🎉',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "TODAY'S CHALLENGE",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.star_rounded,
                  color: AppColors.primary, size: 14),
              const SizedBox(width: 2),
              Text(
                '${activeChallenge.points} pts',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            activeChallenge.title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            activeChallenge.description,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: () {
                controller.completeChallenge(activeChallenge.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '🌱 +${activeChallenge.points} pts! Challenge complete!'),
                    backgroundColor: AppColors.secondary,
                  ),
                );
              },
              child: const Text('Mark as Done ✓'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedTips() {
    if (_featuredTips.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _featuredTips.length,
        itemBuilder: (_, index) =>
            EcoTipCard(tip: _featuredTips[index], compact: true),
      ),
    );
  }

  Widget _buildFeaturedProducts(BuildContext context) {
    if (_featuredProducts.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _featuredProducts.length,
        itemBuilder: (_, index) => ProductCard(
          product: _featuredProducts[index],
          compact: true,
          onTap: () => _showProductDetail(context, _featuredProducts[index]),
        ),
      ),
    );
  }

  void _showProductDetail(BuildContext context, GreenProduct product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => _ProductDetailSheet(product: product),
    );
  }
}

class _ProductDetailSheet extends StatelessWidget {
  final GreenProduct product;
  const _ProductDetailSheet({required this.product});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Product image
            ClipRRect(
              child: Image.network(
                product.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, e, stack) => Container(
                  height: 200,
                  color: AppColors.cardBg,
                  child: const Center(
                    child: Icon(Icons.eco, color: AppColors.primary, size: 48),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + price row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              '🛒 Buy Now feature coming soon!'),
                        ),
                      );
                    },
                    child: const Text('Buy Now 🛒'),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
