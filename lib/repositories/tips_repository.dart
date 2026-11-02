import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/eco_tip.dart';
import '../core/constants/app_constants.dart';

class TipsRepository {
  Future<List<EcoTip>> loadAll() async {
    try {
      final String rawJson =
          await rootBundle.loadString(AppAssets.ecoTipsJson);
      final List<dynamic> decoded = json.decode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => EcoTip.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Log error in debug mode; return empty list to avoid crash
      assert(() {
        // ignore: avoid_print
        print('[TipsRepository] Error loading eco tips: $e');
        return true;
      }());
      return [];
    }
  }

  Future<List<EcoTip>> loadByCategory(String category) async {
    final all = await loadAll();
    return all.where((tip) => tip.category == category).toList();
  }

  Future<List<String>> loadCategories() async {
    final all = await loadAll();
    return all.map((tip) => tip.category).toSet().toList();
  }
}
