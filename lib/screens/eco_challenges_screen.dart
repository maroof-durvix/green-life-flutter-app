import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../core/theme/app_colors.dart';
import '../models/challenge.dart';
import '../widgets/challenge_tile.dart';
import '../widgets/empty_state.dart';

class EcoChallengesScreen extends StatelessWidget {
  const EcoChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();

    if (!controller.challengesLoaded) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    final dailyChallenges =
        controller.challenges.where((c) => c.type == 'daily').toList();
    final weeklyChallenges =
        controller.challenges.where((c) => c.type == 'weekly').toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        _buildScoreHeader(context, controller),
        _buildSectionLabel(context, 'Daily Challenges',
            Icons.today_outlined, AppColors.primary, dailyChallenges),
        if (dailyChallenges.isEmpty)
          const EmptyState(
            icon: Icons.check_circle_outline,
            title: 'No Daily Challenges',
            subtitle: 'Check back soon.',
          )
        else
          ...dailyChallenges.map(
            (c) => ChallengeTile(
              challenge: c,
              onToggle: (_) =>
                  context.read<AppController>().toggleChallenge(c.id),
            ),
          ),
        _buildSectionLabel(context, 'Weekly Challenges',
            Icons.date_range_outlined, AppColors.weekly, weeklyChallenges),
        if (weeklyChallenges.isEmpty)
          const EmptyState(
            icon: Icons.check_circle_outline,
            title: 'No Weekly Challenges',
            subtitle: 'Check back soon.',
          )
        else
          ...weeklyChallenges.map(
            (c) => ChallengeTile(
              challenge: c,
              onToggle: (_) =>
                  context.read<AppController>().toggleChallenge(c.id),
            ),
          ),
        const SizedBox(height: 16),
        // Reset session button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton.icon(
            onPressed: () => _confirmReset(context),
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Session'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.divider),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreHeader(BuildContext context, AppController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Section
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Eco-Score',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You are in the top 15% of Eco Warriors in your city this month. Keep it up!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Right Section (Gauge)
          Expanded(
            flex: 2,
            child: AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(
                painter: ScoreGaugePainter(controller.completionRate),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${controller.ecoScore}',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const Text(
                        'PTS',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
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
    );
  }

  Widget _buildSectionLabel(BuildContext context, String title, IconData icon,
      Color color, List<Challenge> challenges) {
    final completed =
        challenges.where((c) => c.isCompleted).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const Spacer(),
          Text(
            '$completed/${challenges.length}',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Session',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'This will clear all completed challenges and reset your Eco Score to zero for this session.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              context.read<AppController>().resetSession();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Session reset. Start fresh! 🌱')),
              );
            },
            child: const Text('Reset',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class ScoreGaugePainter extends CustomPainter {
  final double progress;

  ScoreGaugePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 10.0;

    // Background track
    final bgPaint = Paint()
      ..color = AppColors.cardBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    if (progress > 0) {
      final rect = Rect.fromCircle(
          center: center, radius: radius - strokeWidth / 2);
      final sweepAngle = 2 * pi * progress;

      // Glow effect using MaskFilter
      final glowPaint = Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawArc(rect, -pi / 2, sweepAngle, false, glowPaint);

      // Solid progress arc
      final progressPaint = Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, -pi / 2, sweepAngle, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ScoreGaugePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
