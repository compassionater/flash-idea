import 'package:hive_flutter/hive_flutter.dart';
import '../models/idea.dart';
import '../models/project.dart';
import '../models/category.dart';

class StorageService {
  static const String ideasBoxName = 'ideas';
  static const String projectsBoxName = 'projects';
  static const String categoriesBoxName = 'categories';

  static late Box<Idea> ideasBox;
  static late Box<Project> projectsBox;
  static late Box<Category> categoriesBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // 注册适配器
    Hive.registerAdapter(IdeaAdapter());
    Hive.registerAdapter(ProjectAdapter());
    Hive.registerAdapter(CategoryAdapter());

    // 打开盒子
    ideasBox = await Hive.openBox<Idea>(ideasBoxName);
    projectsBox = await Hive.openBox<Project>(projectsBoxName);
    categoriesBox = await Hive.openBox<Category>(categoriesBoxName);

    // 初始化默认分类
    await _initDefaultCategories();
  }

  static Future<void> _initDefaultCategories() async {
    if (categoriesBox.isEmpty) {
      final defaultCategories = Category.defaultCategories;
      for (var category in defaultCategories) {
        await categoriesBox.put(category.id, category);
      }
    }
  }

  // Ideas CRUD
  static Future<void> saveIdea(Idea idea) async {
    await ideasBox.put(idea.id, idea);
  }

  static List<Idea> getAllIdeas() {
    return ideasBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static List<Idea> getIdeasByCategory(String categoryId) {
    return ideasBox.values
        .where((idea) => idea.category == categoryId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Idea? getIdea(String id) {
    return ideasBox.get(id);
  }

  static Future<void> deleteIdea(String id) async {
    await ideasBox.delete(id);
  }

  // Projects CRUD
  static Future<void> saveProject(Project project) async {
    await projectsBox.put(project.id, project);
  }

  static List<Project> getAllProjects() {
    return projectsBox.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  static Project? getProject(String id) {
    return projectsBox.get(id);
  }

  static Future<void> deleteProject(String id) async {
    await projectsBox.delete(id);
  }

  // Categories CRUD
  static List<Category> getAllCategories() {
    return categoriesBox.values.toList();
  }

  static Category? getCategory(String id) {
    return categoriesBox.get(id);
  }

  static Future<void> saveCategory(Category category) async {
    await categoriesBox.put(category.id, category);
  }

  static Future<void> deleteCategory(String id) async {
    final category = categoriesBox.get(id);
    if (category != null && !category.isPreset) {
      await categoriesBox.delete(id);
    }
  }
}
