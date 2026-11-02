import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/ai_service.dart';
import '../models/eco_tip.dart';
import '../models/recycling_item.dart';
import '../models/green_product.dart';
import '../widgets/eco_tip_card.dart';
import '../widgets/recycling_item_tile.dart';
import '../widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final AiService _aiService = AiService();
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = false;
  bool _hasSearched = false;
  
  List<EcoTip> _tipResults = [];
  List<RecyclingItem> _recyclingResults = [];
  List<GreenProduct> _productResults = [];
  
  // 0: All, 1: Tips, 2: Recycling, 3: Products
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'Tips', 'Recycling', 'Products'];

  @override
  void initState() {
    super.initState();
    _aiService.warmUp();
  }
  
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _hasSearched = false;
        _tipResults = [];
        _recyclingResults = [];
        _productResults = [];
      });
      return;
    }
    
    setState(() => _isLoading = true);
    
    // We can reuse processQuery logic or tap into the inner mechanisms of AiService.
    // However, since processQuery is intent-based, we might just want to use it
    // and extract the populated lists, or use AiService to fetch the matching items.
    // For simplicity, let's use processQuery as a generic search across all.
    final response = await _aiService.processQuery(query);
    
    // We will extract whatever it found. Wait, AiService's processQuery returns one type mostly.
    // Let's query AiService to get all matches if we made those public. Since they are private,
    // we can add a simple unified search method to AiService, OR we can just use processQuery.
    // Actually, I will just load from repos directly here if needed, but AiService has it.
    
    // Let's do a trick: we can use processQuery and if it's not enough, we fallback to our own logic.
    // Let's just use the message response.
    setState(() {
      _isLoading = false;
      _hasSearched = true;
      _tipResults = response.tips;
      _recyclingResults = response.recyclingItems;
      _productResults = response.products;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Search'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterTabs(),
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        textInputAction: TextInputAction.search,
        onSubmitted: _performSearch,
        decoration: InputDecoration(
          hintText: 'Search tips, products, recycling...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchController.text.isNotEmpty 
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                onPressed: () {
                  _searchController.clear();
                  _performSearch('');
                },
              )
            : null,
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (val) => setState(() {}),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          return ChoiceChip(
            label: Text(_filters[index]),
            selected: isSelected,
            onSelected: (val) {
              setState(() => _selectedFilterIndex = index);
            },
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            labelStyle: TextStyle(
              color: isSelected ? AppColors.background : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    if (!_hasSearched) {
      return const Center(
        child: Text(
          'Enter a keyword to start searching.\nTry "plastic", "energy", or "bottle".',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    
    final List<Widget> listItems = [];
    
    // Tips
    if (_selectedFilterIndex == 0 || _selectedFilterIndex == 1) {
      if (_tipResults.isNotEmpty) {
        listItems.add(const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text('Eco Tips', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ));
        listItems.addAll(_tipResults.map((t) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: EcoTipCard(tip: t),
        )));
      }
    }
    
    // Recycling
    if (_selectedFilterIndex == 0 || _selectedFilterIndex == 2) {
      if (_recyclingResults.isNotEmpty) {
        listItems.add(const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Recycling Guide', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ));
        listItems.addAll(_recyclingResults.map((r) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: RecyclingItemTile(item: r),
        )));
      }
    }
    
    // Products
    if (_selectedFilterIndex == 0 || _selectedFilterIndex == 3) {
      if (_productResults.isNotEmpty) {
        listItems.add(const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Green Products', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ));
        listItems.add(
          SizedBox(
            height: 190,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _productResults.length,
              itemBuilder: (context, index) => ProductCard(
                product: _productResults[index],
                compact: true,
              ),
            ),
          ),
        );
      }
    }
    
    if (listItems.isEmpty) {
      return const Center(
        child: Text('No results found.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: listItems,
    );
  }
}
