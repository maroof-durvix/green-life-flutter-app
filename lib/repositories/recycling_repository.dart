import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/recycling_item.dart';
import '../core/constants/app_constants.dart';

class RecyclingRepository {
  Future<List<RecyclingItem>> loadAll() async {
    try {
      final String rawJson =
          await rootBundle.loadString(AppAssets.recyclingGuideJson);
      final List<dynamic> decoded = json.decode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => RecyclingItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      assert(() {
        // ignore: avoid_print
        print('[RecyclingRepository] Error loading recycling guide: $e');
        return true;
      }());
      return [];
    }
  }

  Future<List<RecyclingItem>> loadByCategory(String category) async {
    final all = await loadAll();
    return all.where((item) => item.category == category).toList();
  }

  Future<List<RecyclingItem>> search(String query) async {
    final all = await loadAll();
    final lower = query.toLowerCase();
    return all
        .where((item) => item.name.toLowerCase().contains(lower))
        .toList();
  }

  Future<List<String>> loadCategories() async {
    final all = await loadAll();
    return all.map((item) => item.category).toSet().toList();
  }
}
