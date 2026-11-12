import 'package:flutter/foundation.dart';

class FavoriteStore {
  FavoriteStore._();

  static final ValueNotifier<List<Map<String, Object>>> items =
      ValueNotifier<List<Map<String, Object>>>([]);

  static bool contains(String title) =>
      items.value.any((product) => product['title'] == title);

  static void toggle(Map<String, Object> product) {
    final title = product['title'];
    final updated = List<Map<String, Object>>.from(items.value);
    final index = updated.indexWhere((item) => item['title'] == title);
    if (index >= 0) {
      updated.removeAt(index);
    } else {
      updated.add(Map<String, Object>.from(product));
    }
    items.value = updated;
  }

  static int remove(String title) {
    final updated = List<Map<String, Object>>.from(items.value);
    final index = updated.indexWhere((item) => item['title'] == title);
    if (index >= 0) {
      updated.removeAt(index);
      items.value = updated;
    }
    return index;
  }

  static void restore(Map<String, Object> product, int index) {
    if (contains(product['title'] as String)) return;
    final updated = List<Map<String, Object>>.from(items.value);
    final insertIndex = index.clamp(0, updated.length).toInt();
    updated.insert(insertIndex, Map<String, Object>.from(product));
    items.value = updated;
  }
}
