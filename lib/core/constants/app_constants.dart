abstract class AppRoutes {
  static const String splash = '/';
  static const String userSetup = '/user-setup';
  static const String main = '/main';
  static const String home = '/home';
  static const String ecoTips = '/eco-tips';
  static const String recyclingGuide = '/recycling-guide';
  static const String greenProducts = '/green-products';
  static const String ecoChallenges = '/eco-challenges';
  static const String aiAssistant = '/ai-assistant';
  static const String ecoScore = '/eco-score';
  static const String gallery = '/gallery';
  static const String aboutUs = '/about-us';
  static const String contact = '/contact';
}

abstract class AppAssets {
  // Images
  static const String logo = 'assets/images/logo.png';
  static const String favicon = 'assets/images/favicon.png';

  // JSON Data
  static const String ecoTipsJson = 'assets/data/eco_tips.json';
  static const String recyclingGuideJson = 'assets/data/recycling_guide.json';
  static const String greenProductsJson = 'assets/data/green_products.json';
  static const String challengesJson = 'assets/data/challenges.json';
}

abstract class AppStrings {
  static const String appName = 'GreenLife';
  static const String appTagline = 'Smart Eco-Friendly Lifestyle Portal';
  static const String techWizTag = 'TechWiz 7 — The World Tech Championship';

  // User Setup — Preference Areas (from SRS.md §2)
  static const List<String> preferenceAreas = [
    'Recycling',
    'Energy',
    'Water',
    'Sustainable Shopping',
  ];

  // Bottom Nav labels
  static const String navHome = 'Home';
  static const String navTips = 'Tips';
  static const String navRecycle = 'Recycle';
  static const String navProducts = 'Products';
  static const String navAI = 'AI';
  static const String navChallenges = 'Challenges';
}
