import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';
import '../services/storage_service.dart';

class ProjectProvider extends ChangeNotifier {
  List<Project> _projects = [];
  String? _selectedStatus;
  final _uuid = const Uuid();

  List<Project> get projects {
    if (_selectedStatus == null) {
      return _projects;
    }
    return _projects.where((p) => p.status == _selectedStatus).toList();
  }

  List<Project> get allProjects => _projects;

  String? get selectedStatus => _selectedStatus;

  void loadProjects() {
    _projects = StorageService.getAllProjects();
    notifyListeners();
  }

  void setSelectedStatus(String? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  Future<void> addProject({
    required String title,
    required String description,
    List<String> ideaIds = const [],
  }) async {
    final now = DateTime.now();
    final project = Project(
      id: _uuid.v4(),
      title: title,
      description: description,
      ideaIds: ideaIds,
      createdAt: now,
      updatedAt: now,
    );
    await StorageService.saveProject(project);
    _projects.insert(0, project);
    notifyListeners();
  }

  Future<void> updateProject(Project project) async {
    final updated = project.copyWith(updatedAt: DateTime.now());
    await StorageService.saveProject(updated);
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteProject(String id) async {
    await StorageService.deleteProject(id);
    _projects.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Future<void> updateProjectStatus(String projectId, String status) async {
    final project = _projects.firstWhere((p) => p.id == projectId);
    await updateProject(project.copyWith(status: status));
  }

  Future<void> updateRecordingStatus(String projectId, String recordingStatus) async {
    final project = _projects.firstWhere((p) => p.id == projectId);
    await updateProject(project.copyWith(recordingStatus: recordingStatus));
  }

  Future<void> addIdeaToProject(String projectId, String ideaId) async {
    final project = _projects.firstWhere((p) => p.id == projectId);
    final newIdeaIds = List<String>.from(project.ideaIds)..add(ideaId);
    await updateProject(project.copyWith(ideaIds: newIdeaIds));
  }

  int get todoCount => _projects.where((p) => p.status == 'todo').length;
  int get inProgressCount => _projects.where((p) => p.status == 'in_progress').length;
  int get completedCount => _projects.where((p) => p.status == 'completed').length;
}
