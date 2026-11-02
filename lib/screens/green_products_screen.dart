import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/green_product.dart';
import '../repositories/products_repository.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chips.dart';
import '../widgets/empty_state.dart';

class GreenProductsScreen extends StatefulWidget {
  const GreenProductsScreen({super.key});

  @override
  State<GreenProductsScreen> createState() => _GreenProductsScreenState();
}

class _GreenProductsScreenState extends State<GreenProductsScreen> {
  final _repo = ProductsRepository();
  List<GreenProduct> _allProducts = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await _repo.loadAll();
    final cats = await _repo.loadCategories();
    if (mounted) {
      setState(() {
        _allProducts = products;
        _categories = ['All', ...cats..sort()];
        _loading = false;
      });
    }
  }

  List<GreenProduct> get _filtered {
    if (_selectedCategory == 'All') return _allProducts;
    return _allProducts
        .where((p) => p.category == _selectedCategory)
        .toList();
  }

  void _showDetail(BuildContext context, GreenProduct product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ProductDetailSheet(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Icon(Icons.shopping_bag, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Green Products',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              if (!_loading)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_filtered.length}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Category chips
        if (!_loading && _categories.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CategoryChips(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onSelected: (cat) =>
                  setState(() => _selectedCategory = cat),
            ),
          ),
        const Divider(color: AppColors.divider, height: 1),
        // Product grid
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              : _filtered.isEmpty
                  ? const EmptyState(
                      icon: Icons.shopping_bag_outlined,
                      title: 'No Products Found',
                      subtitle:
                          'Try selecting a different category.',
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: _filtered.length,
                      itemBuilder: (_, index) {
                        final product = _filtered[index];
                        return ProductCard(
                          product: product,
                          onTap: () => _showDetail(context, product),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class _ProductDetailSheet extends StatelessWidget {
  final GreenProduct product;
  const _ProductDetailSheet({required this.product});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      minChildSize: 0.45,
      expand: false,
      builder: (_, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
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
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, e, stack) => Container(
                  height: 220,
                  color: AppColors.cardBg,
                  child: const Center(
                    child:
                        Icon(Icons.eco, color: AppColors.primary, size: 56),
                  ),
                ),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 220,
                    color: AppColors.cardBg,
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
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
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  // Non-functional Buy Now — SRS §5
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🛒 Buy Now feature coming soon!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text('Buy Now'),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
