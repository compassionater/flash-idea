import 'package:hive/hive.dart';

part 'idea.g.dart';

@HiveType(typeId: 0)
class Idea extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  String? imagePath;

  @HiveField(4)
  String? audioPath;

  @HiveField(5)
  String category;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  bool isProject;

  @HiveField(8)
  String? projectId;

  @HiveField(9)
  String recordingType; // 'text', 'image', 'audio'

  Idea({
    required this.id,
    required this.title,
    required this.content,
    this.imagePath,
    this.audioPath,
    required this.category,
    required this.createdAt,
    this.isProject = false,
    this.projectId,
    this.recordingType = 'text',
  });

  Idea copyWith({
    String? id,
    String? title,
    String? content,
    String? imagePath,
    String? audioPath,
    String? category,
    DateTime? createdAt,
    bool? isProject,
    String? projectId,
    String? recordingType,
  }) {
    return Idea(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imagePath: imagePath ?? this.imagePath,
      audioPath: audioPath ?? this.audioPath,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isProject: isProject ?? this.isProject,
      projectId: projectId ?? this.projectId,
      recordingType: recordingType ?? this.recordingType,
    );
  }
}
