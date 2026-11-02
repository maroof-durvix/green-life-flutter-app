import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import 'home_screen.dart';
import 'eco_tips_screen.dart';
import 'recycling_guide_screen.dart';
import 'green_products_screen.dart';
import 'eco_challenges_screen.dart';
import 'ai_assistant_screen.dart';
import 'search_screen.dart';
import 'gallery_screen.dart';
import 'about_screen.dart';
import 'contact_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // IndexedStack children — state preserved on tab switch
  static const List<Widget> _screens = [
    HomeScreen(),
    EcoTipsScreen(),
    RecyclingGuideScreen(),
    GreenProductsScreen(),
    EcoChallengesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Ensure challenges are loaded when the main shell mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppController>().loadChallenges();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, controller),
      body: IndexedStack(
        index: controller.currentTabIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(controller),
      drawer: _buildDrawer(context, controller),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, AppController controller) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
          tooltip: 'Menu',
        ),
      ),
      title: Image.asset(
        AppAssets.logo,
        height: 40,
        errorBuilder: (_, e, stack) => const Icon(
          Icons.eco,
          color: AppColors.primary,
          size: 32,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.textPrimary),
          tooltip: 'Global Search',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          ),
        ),
        // Live EcoScore badge
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => _showScoreDialog(context, controller),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.primary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${controller.ecoScore}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(AppController controller) {
    return BottomNavigationBar(
      currentIndex: controller.currentTabIndex,
      onTap: (index) => controller.setTabIndex(index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: AppStrings.navHome,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.eco_outlined),
          activeIcon: Icon(Icons.eco),
          label: AppStrings.navTips,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.recycling_outlined),
          activeIcon: Icon(Icons.recycling),
          label: AppStrings.navRecycle,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          activeIcon: Icon(Icons.shopping_bag),
          label: AppStrings.navProducts,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment),
          label: AppStrings.navChallenges,
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, AppController controller) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppColors.primary.withValues(alpha: 0.08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    AppAssets.logo,
                    height: 50,
                    errorBuilder: (_, e, stack) => const Icon(
                      Icons.eco,
                      color: AppColors.primary,
                      size: 40,
                    ),
                  ),
                  if (controller.isUserSetupComplete) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Hi, ${controller.userName} 👋',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      controller.preferredArea,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Eco Score tile
            ListTile(
              leading: const Icon(Icons.star_rounded, color: AppColors.primary),
              title: Text(
                'Eco Score: ${controller.ecoScore} pts',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '${controller.completedCount} / ${controller.totalChallenges} challenges done',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 8),
            _drawerItem(Icons.smart_toy_outlined, 'AI Eco Assistant', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AiAssistantScreen()));
            }),
            _drawerItem(Icons.search_outlined, 'Global Search', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
            }),
            _drawerItem(Icons.photo_library_outlined, 'Awareness Gallery', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen()));
            }),
            const Divider(color: AppColors.divider, height: 1, indent: 20, endIndent: 20),
            _drawerItem(Icons.edit_outlined, 'Edit Profile', () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.userSetup);
            }),
            _drawerItem(Icons.info_outline, 'About GreenLife', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
            }),
            _drawerItem(Icons.mail_outline, 'Contact & Feedback', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactScreen()));
            }),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppStrings.techWizTag,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(label,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
      onTap: onTap,
    );
  }

  void _showScoreDialog(BuildContext context, AppController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.star_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Eco Score',
                style: TextStyle(color: AppColors.textPrimary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${controller.ecoScore}',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 56,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'points earned this session',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: controller.completionRate,
              backgroundColor: AppColors.cardBg,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 6),
            Text(
              '${controller.completedCount} of ${controller.totalChallenges} challenges completed',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

}
