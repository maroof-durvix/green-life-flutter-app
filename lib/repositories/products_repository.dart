import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/green_product.dart';
import '../core/constants/app_constants.dart';

class ProductsRepository {
  Future<List<GreenProduct>> loadAll() async {
    try {
      final String rawJson =
          await rootBundle.loadString(AppAssets.greenProductsJson);
      final List<dynamic> decoded = json.decode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => GreenProduct.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      assert(() {
        // ignore: avoid_print
        print('[ProductsRepository] Error loading green products: $e');
        return true;
      }());
      return [];
    }
  }

  Future<List<GreenProduct>> loadByCategory(String category) async {
    final all = await loadAll();
    return all.where((p) => p.category == category).toList();
  }

  Future<List<GreenProduct>> search(String query) async {
    final all = await loadAll();
    final lower = query.toLowerCase();
    return all
        .where((p) =>
            p.name.toLowerCase().contains(lower) ||
            p.description.toLowerCase().contains(lower))
        .toList();
  }

  Future<List<String>> loadCategories() async {
    final all = await loadAll();
    return all.map((p) => p.category).toSet().toList();
  }
}
