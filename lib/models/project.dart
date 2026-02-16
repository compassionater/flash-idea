import 'package:hive/hive.dart';

part 'project.g.dart';

@HiveType(typeId: 1)
class Project extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String status; // 'todo', 'in_progress', 'completed'

  @HiveField(4)
  String recordingStatus; // 'not_started', 'recording', 'recorded'

  @HiveField(5)
  List<String> ideaIds;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  Project({
    required this.id,
    required this.title,
    required this.description,
    this.status = 'todo',
    this.recordingStatus = 'not_started',
    required this.ideaIds,
    required this.createdAt,
    required this.updatedAt,
  });

  Project copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? recordingStatus,
    List<String>? ideaIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      recordingStatus: recordingStatus ?? this.recordingStatus,
      ideaIds: ideaIds ?? this.ideaIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
