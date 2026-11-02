import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/recycling_item.dart';
import '../repositories/recycling_repository.dart';
import '../widgets/recycling_item_tile.dart';
import '../widgets/category_chips.dart';
import '../widgets/empty_state.dart';

class RecyclingGuideScreen extends StatefulWidget {
  const RecyclingGuideScreen({super.key});

  @override
  State<RecyclingGuideScreen> createState() =>
      _RecyclingGuideScreenState();
}

class _RecyclingGuideScreenState extends State<RecyclingGuideScreen> {
  final _repo = RecyclingRepository();
  final _searchController = TextEditingController();

  List<RecyclingItem> _allItems = [];
  List<String> _categories = [];

  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    final items = await _repo.loadAll();
    final cats = await _repo.loadCategories();

    if (mounted) {
      setState(() {
        _allItems = items;
        _categories = ['All', ...cats..sort()];
        _loading = false;
      });
    }
  }

  List<RecyclingItem> get _filteredItems {
    return _allItems.where((item) {
      final matchesCat =
          _selectedCategory == 'All' ||
          item.category == _selectedCategory;

      final matchesSearch =
          _searchQuery.isEmpty ||
          item.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      return matchesCat && matchesSearch;
    }).toList();
  }

  // ============================================================
  // POPUP
  // ============================================================

  void _showItemPopup(RecyclingItem item) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 450,
            ),

            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  // HEADER
                  Row(
                    children: [

                      Container(
                        width: 55,
                        height: 55,

                        decoration: BoxDecoration(
                          color:
                              AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.recycling,
                          color: AppColors.primary,
                          size: 30,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // CATEGORY BOX
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: Row(
                      children: [

                        const Icon(
                          Icons.category_outlined,
                          color: AppColors.primary,
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [

                              const Text(
                                'Category',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                item.category,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // CLOSE BUTTON
                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },

                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // HEADER
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),

          child: Row(
            children: [

              const Icon(
                Icons.recycling,
                color: AppColors.primary,
                size: 22,
              ),

              const SizedBox(width: 8),

              Text(
                'Recycling Guide',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),

              const SizedBox(width: 8),

              if (!_loading)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),

                  decoration: BoxDecoration(
                    color:
                        AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: Text(
                    '${_filteredItems.length}',
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

        // SEARCH BAR
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),

          child: TextField(
            controller: _searchController,

            style: const TextStyle(
              color: AppColors.textPrimary,
            ),

            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },

            decoration: InputDecoration(
              hintText:
                  'Search items (e.g. bottle, battery...)',

              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.primary,
              ),

              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: AppColors.textSecondary,
                      ),

                      onPressed: () {
                        _searchController.clear();

                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // CATEGORY CHIPS
        if (!_loading && _categories.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),

            child: CategoryChips(
              categories: _categories,
              selectedCategory: _selectedCategory,

              onSelected: (cat) {
                setState(() {
                  _selectedCategory = cat;
                });
              },
            ),
          ),

        const Divider(
          color: AppColors.divider,
          height: 1,
        ),

        // ITEMS
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                )
              : _filteredItems.isEmpty
                  ? EmptyState(
                      icon: Icons.search_off_outlined,

                      title: _searchQuery.isNotEmpty
                          ? 'No results for "$_searchQuery"'
                          : 'No items found',

                      subtitle:
                          'Try a different category or search term.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(
                        top: 8,
                        bottom: 80,
                      ),

                      itemCount: _filteredItems.length,

                      itemBuilder: (_, index) {
                        final item = _filteredItems[index];

                        return GestureDetector(
                          onTap: () {
                            _showItemPopup(item);
                          },

                          child: RecyclingItemTile(
                            item: item,
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
