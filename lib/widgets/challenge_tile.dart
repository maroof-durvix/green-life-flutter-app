import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/challenge.dart';

class ChallengeTile extends StatelessWidget {
  final Challenge challenge;
  final ValueChanged<bool> onToggle;

  const ChallengeTile({
    super.key,
    required this.challenge,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDaily = challenge.type == 'daily';
    final typeColor = isDaily ? AppColors.primary : AppColors.weekly;

    return GestureDetector(
      onTap: () => onToggle(!challenge.isCompleted),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: challenge.isCompleted
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: challenge.isCompleted
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.cardBorder,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 2, right: 12),
              decoration: BoxDecoration(
                color: challenge.isCompleted
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: challenge.isCompleted
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  width: 1.5,
                ),
              ),
              child: challenge.isCompleted
                  ? const Icon(Icons.check, color: AppColors.background, size: 16)
                  : null,
            ),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          challenge.type == 'daily' ? 'DAILY' : 'WEEKLY',
                          style: TextStyle(
                            color: typeColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Points badge
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppColors.secondary, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            '${challenge.points} pts',
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    challenge.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: challenge.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: challenge.isCompleted
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    challenge.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
