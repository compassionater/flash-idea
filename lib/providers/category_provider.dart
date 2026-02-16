import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart' as models;
import '../services/storage_service.dart';

class CategoryProvider extends ChangeNotifier {
  List<models.Category> _categories = [];
  final _uuid = const Uuid();

  List<models.Category> get categories => _categories;

  void loadCategories() {
    _categories = StorageService.getAllCategories();
    notifyListeners();
  }

  Future<void> addCategory({
    required String name,
    required int colorValue,
  }) async {
    final category = models.Category(
      id: _uuid.v4(),
      name: name,
      colorValue: colorValue,
      isPreset: false,
    );
    await StorageService.saveCategory(category);
    _categories.add(category);
    notifyListeners();
  }

  Future<void> updateCategory(models.Category category) async {
    await StorageService.saveCategory(category);
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    await StorageService.deleteCategory(id);
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  models.Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
