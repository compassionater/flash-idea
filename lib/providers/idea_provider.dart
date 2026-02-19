import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/idea.dart';
import '../services/storage_service.dart';

class IdeaProvider extends ChangeNotifier {
  List<Idea> _ideas = [];
  String? _selectedCategory;
  final _uuid = const Uuid();

  List<Idea> get ideas {
    if (_selectedCategory == null) {
      return _ideas;
    }
    return _ideas.where((idea) => idea.category == _selectedCategory).toList();
  }

  List<Idea> get allIdeas => _ideas;

  String? get selectedCategory => _selectedCategory;

  void loadIdeas() {
    _ideas = StorageService.getAllIdeas();
    notifyListeners();
  }

  void setSelectedCategory(String? categoryId) {
    _selectedCategory = categoryId;
    notifyListeners();
  }

  Future<void> addIdea({
    required String title,
    required String content,
    String? imagePath,
    String? audioPath,
    required String category,
    String recordingType = 'text',
  }) async {
    final idea = Idea(
      id: _uuid.v4(),
      title: title,
      content: content,
      imagePath: imagePath,
      audioPath: audioPath,
      category: category,
      createdAt: DateTime.now(),
      recordingType: recordingType,
    );
    await StorageService.saveIdea(idea);
    _ideas.insert(0, idea);
    notifyListeners();
  }

  Future<void> updateIdea(Idea idea) async {
    await StorageService.saveIdea(idea);
    final index = _ideas.indexWhere((i) => i.id == idea.id);
    if (index != -1) {
      _ideas[index] = idea;
      notifyListeners();
    }
  }

  Future<void> deleteIdea(String id) async {
    await StorageService.deleteIdea(id);
    _ideas.removeWhere((idea) => idea.id == id);
    notifyListeners();
  }

  Future<void> convertToProject(String ideaId) async {
    final idea = _ideas.firstWhere((i) => i.id == ideaId);
    final updatedIdea = idea.copyWith(
      status: IdeaStatus.planning,
      projectId: ideaId,
    );
    await updateIdea(updatedIdea);
  }

  Future<void> updateIdeaStatus(String ideaId, IdeaStatus newStatus) async {
    final idea = _ideas.firstWhere((i) => i.id == ideaId);
    final updatedIdea = idea.copyWith(status: newStatus);
    await updateIdea(updatedIdea);
  }

  List<Idea> searchIdeas(String query) {
    if (query.isEmpty) return _ideas;
    final lowerQuery = query.toLowerCase();
    return _ideas.where((idea) {
      return idea.title.toLowerCase().contains(lowerQuery) ||
          idea.content.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
