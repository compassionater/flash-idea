import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 2)
class Category extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int colorValue;

  @HiveField(3)
  bool isPreset;

  Category({
    required this.id,
    required this.name,
    required this.colorValue,
    this.isPreset = false,
  });

  Category copyWith({
    String? id,
    String? name,
    int? colorValue,
    bool? isPreset,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      isPreset: isPreset ?? this.isPreset,
    );
  }

  // 默认预设分类
  static List<Category> get defaultCategories => [
    Category(id: 'life', name: '生活', colorValue: 0xFF4CAF50, isPreset: true),
    Category(id: 'creative', name: '创意', colorValue: 0xFF9C27B0, isPreset: true),
    Category(id: 'work', name: '工作', colorValue: 0xFF2196F3, isPreset: true),
    Category(id: 'emotion', name: '情感', colorValue: 0xFFE91E63, isPreset: true),
    Category(id: 'learning', name: '学习', colorValue: 0xFFFF9800, isPreset: true),
    Category(id: 'travel', name: '旅行', colorValue: 0xFF00BCD4, isPreset: true),
    Category(id: 'food', name: '美食', colorValue: 0xFFFF5722, isPreset: true),
    Category(id: 'tech', name: '科技', colorValue: 0xFF607D8B, isPreset: true),
    Category(id: 'other', name: '其他', colorValue: 0xFF9E9E9E, isPreset: true),
  ];
}
