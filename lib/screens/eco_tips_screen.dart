import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/eco_tip.dart';
import '../repositories/tips_repository.dart';
import '../widgets/eco_tip_card.dart';
import '../widgets/category_chips.dart';
import '../widgets/empty_state.dart';

class EcoTipsScreen extends StatefulWidget {
  const EcoTipsScreen({super.key});

  @override
  State<EcoTipsScreen> createState() => _EcoTipsScreenState();
}

class _EcoTipsScreenState extends State<EcoTipsScreen> {
  final _repo = TipsRepository();
  List<EcoTip> _allTips = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  Future<void> _loadTips() async {
    final tips = await _repo.loadAll();
    final rawCats = await _repo.loadCategories();
    if (mounted) {
      setState(() {
        _allTips = tips;
        _categories = ['All', ...rawCats..sort()];
        _loading = false;
      });
    }
  }

  List<EcoTip> get _filteredTips {
    if (_selectedCategory == 'All') return _allTips;
    return _allTips
        .where((t) => t.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Screen title bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Icon(Icons.eco, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Eco Tips',
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
                    '${_filteredTips.length}',
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
        // Category filter chips
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
        // Tip list
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              : _filteredTips.isEmpty
                  ? const EmptyState(
                      icon: Icons.eco_outlined,
                      title: 'No Tips Found',
                      subtitle: 'Try selecting a different category.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 80),
                      itemCount: _filteredTips.length,
                      itemBuilder: (_, index) =>
                          EcoTipCard(tip: _filteredTips[index]),
                    ),
        ),
      ],
    );
  }
}
