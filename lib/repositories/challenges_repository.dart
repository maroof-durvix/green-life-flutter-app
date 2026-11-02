import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/challenge.dart';
import '../core/constants/app_constants.dart';

class ChallengesRepository {
  Future<List<Challenge>> loadAll() async {
    try {
      final String rawJson =
          await rootBundle.loadString(AppAssets.challengesJson);
      final List<dynamic> decoded = json.decode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => Challenge.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      assert(() {
        // ignore: avoid_print
        print('[ChallengesRepository] Error loading challenges: $e');
        return true;
      }());
      return [];
    }
  }

  Future<List<Challenge>> loadDaily() async {
    final all = await loadAll();
    return all.where((c) => c.type == 'daily').toList();
  }

  Future<List<Challenge>> loadWeekly() async {
    final all = await loadAll();
    return all.where((c) => c.type == 'weekly').toList();
  }
}
