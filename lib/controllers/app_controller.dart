import 'package:flutter/foundation.dart';
import '../models/challenge.dart';
import '../repositories/challenges_repository.dart';

class AppController extends ChangeNotifier {
  // ── Dependencies ──────────────────────────────────────────────────────────
  final ChallengesRepository _challengesRepo = ChallengesRepository();

  // ── User Profile State ────────────────────────────────────────────────────
  String _userName = '';
  String _preferredArea = ''; // One of: Recycling | Energy | Water | Sustainable Shopping

  String get userName => _userName;
  String get preferredArea => _preferredArea;

  bool get isUserSetupComplete =>
      _userName.trim().isNotEmpty && _preferredArea.isNotEmpty;

  // ── Navigation State ──────────────────────────────────────────────────────
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      notifyListeners();
    }
  }

  // ── Challenge & Score State ───────────────────────────────────────────────
  List<Challenge> _challenges = [];
  final Set<String> _completedChallengeIds = {};
  bool _challengesLoaded = false;

  List<Challenge> get challenges => List.unmodifiable(_challenges);
  Set<String> get completedChallengeIds =>
      Set.unmodifiable(_completedChallengeIds);
  bool get challengesLoaded => _challengesLoaded;

  int get ecoScore {
    return _challenges
        .where((c) => _completedChallengeIds.contains(c.id))
        .fold(0, (sum, c) => sum + c.points);
  }

  int get completedCount => _completedChallengeIds.length;

  int get totalChallenges => _challenges.length;

  double get completionRate =>
      _challenges.isEmpty ? 0.0 : completedCount / totalChallenges;

  // ── Methods ───────────────────────────────────────────────────────────────

  void setupUser({required String name, required String area}) {
    _userName = name.trim();
    _preferredArea = area.trim();
    notifyListeners();
  }

  Future<void> loadChallenges() async {
    if (_challengesLoaded) return; // Avoid re-loading during same session
    _challenges = await _challengesRepo.loadAll();
    _challengesLoaded = true;
    notifyListeners();
  }

  void completeChallenge(String challengeId) {
    if (_completedChallengeIds.contains(challengeId)) return;
    _completedChallengeIds.add(challengeId);

    // Update the mutable isCompleted flag on the model object
    final idx = _challenges.indexWhere((c) => c.id == challengeId);
    if (idx != -1) {
      _challenges[idx].isCompleted = true;
    }
    notifyListeners();
  }

  void uncompleteChallenge(String challengeId) {
    if (!_completedChallengeIds.contains(challengeId)) return;
    _completedChallengeIds.remove(challengeId);

    final idx = _challenges.indexWhere((c) => c.id == challengeId);
    if (idx != -1) {
      _challenges[idx].isCompleted = false;
    }
    notifyListeners();
  }

  void toggleChallenge(String challengeId) {
    if (_completedChallengeIds.contains(challengeId)) {
      uncompleteChallenge(challengeId);
    } else {
      completeChallenge(challengeId);
    }
  }

  bool isChallengeCompleted(String challengeId) =>
      _completedChallengeIds.contains(challengeId);

  void resetSession() {
    _completedChallengeIds.clear();
    for (final c in _challenges) {
      c.isCompleted = false;
    }
    notifyListeners();
  }

  void resetAll() {
    _userName = '';
    _preferredArea = '';
    resetSession();
  }
}
