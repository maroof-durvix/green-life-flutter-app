import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/recycling_item.dart';

Color _categoryColor(String category) {
  switch (category) {
    case 'Paper':
      return AppColors.materialPaper;
    case 'Plastic':
      return AppColors.materialPlastic;
    case 'Glass':
      return AppColors.materialGlass;
    case 'Metal':
      return AppColors.materialMetal;
    case 'Organic':
      return AppColors.secondary;
    case 'E-Waste':
      return AppColors.error;
    default:
      return AppColors.primary;
  }
}

String _itemImageUrl(String category) {
  switch (category) {
    case 'Paper':
      return 'assets/images/rec_paper.jpg';
    case 'Plastic':
      return 'assets/images/rec_plastic.jpg';
    case 'Glass':
      return 'assets/images/rec_glass.jpg';
    case 'Metal':
      return 'assets/images/rec_metal.jpg';
    case 'Organic':
      return 'assets/images/rec_organic.jpg';
    case 'E-Waste':
      return 'assets/images/rec_ewaste.jpg';
    default:
      return 'assets/images/rec_default.jpg';
  }
}

class RecyclingItemTile extends StatelessWidget {
  final RecyclingItem item;

  const RecyclingItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor(item.category);
    final imageUrl = _itemImageUrl(item.category);

    return GestureDetector(
      onTap: () => _showDetail(context, catColor, imageUrl),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image strip
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
            child: Image.asset(
              imageUrl,
              width: 70,
              height: 120, // rough matching height
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 70,
                height: 120,
                color: catColor.withValues(alpha: 0.15),
                child: Center(child: Icon(Icons.recycling, color: catColor, size: 28)),
              ),
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row: category + recyclable badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.category,
                          style: TextStyle(
                            color: catColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: item.isRecyclable
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : AppColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.isRecyclable ? '♻ Recyclable' : '✕ Not Recyclable',
                          style: TextStyle(
                            color: item.isRecyclable
                                ? AppColors.primary
                                : AppColors.error,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.disposalMethod,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  void _showDetail(BuildContext context, Color color, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.asset(
                imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: color.withValues(alpha: 0.15),
                  child: Center(child: Icon(Icons.recycling, color: color, size: 48)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.category,
                          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.isRecyclable
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : AppColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.isRecyclable ? '♻ Recyclable' : '✕ Not Recyclable',
                          style: TextStyle(
                            color: item.isRecyclable ? AppColors.primary : AppColors.error,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.disposalMethod,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close', style: TextStyle(color: AppColors.primary)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
