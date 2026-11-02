# GreenLife 🌿

**Smart Eco-Friendly Lifestyle Portal**

GreenLife is a Flutter-based application designed to encourage and track eco-friendly habits. It provides actionable tips, a comprehensive recycling guide, sustainable product recommendations, AI-powered eco assistance, and daily green challenges to help users reduce their carbon footprint.

*Built for TechWiz 7 — The World Tech Championship*

## ✨ Features
- **AI Eco Assistant**: Fully local, rule-based AI engine that parses natural language queries and returns contextual eco-tips, recycling instructions, and sustainable product suggestions.
- **Global Search**: Unified search engine querying across Tips, Recycling Items, and Green Products.
- **Eco Challenges**: Daily and weekly challenges to track and gamify eco-friendly habits, with a dynamic Eco Score system.
- **Recycling Guide**: Searchable directory of recyclable items, disposal methods, and visual category badges.
- **Awareness Gallery**: Grid layout showcasing eco-friendly media and infographics.
- **100% Local**: No external API dependencies. All data is securely loaded from asynchronous local JSON assets.

## 🏗️ Architecture

GreenLife is built using a clean, layered architecture:
- **Presentation Layer**: Custom widgets, screens, and the `MainShell` using an `IndexedStack` to preserve state.
- **State Management**: `ChangeNotifierProvider` globally manages the `AppController` state (EcoScore, User Preferences).
- **Service Layer**: `AiService` handles intent classification and keyword extraction.
- **Data Layer**: Repositories (`TipsRepository`, `RecyclingRepository`, `ProductsRepository`) parse strictly typed Dart models from `assets/data/*.json`.

## 🛠️ Setup & Execution

### Prerequisites
- Flutter SDK (v3.19+)
- Dart SDK
- Chrome / Edge (for web testing) or an Android/iOS emulator.

### Running the App
1. Clone the repository and navigate to the project root.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run -d chrome
   ```
   *Note: If port 8080 is blocked by another server instance, Flutter will automatically launch on an available port, or you can specify one using `--web-port=3000`.*

### Code Quality Assurance
To verify codebase integrity (zero warnings/lints):
```bash
flutter analyze
```

## 🎨 Design System
All visual elements strictly adhere to the `AppColors` token system to ensure a consistent Dark Mode experience (`#121212` background, `#2ECC71` primary accent, off-white typography).

---
*GreenLife — Empowering a sustainable future, one challenge at a time.*
