import 'package:hive/hive.dart';

part 'idea.g.dart';

/// 灵感状态枚举
@HiveType(typeId: 3)
enum IdeaStatus {
  @HiveField(0)
  idea,      // 灵感 - 默认状态

  @HiveField(1)
  planning,  // 策划中

  @HiveField(2)
  inProgress, // 制作中

  @HiveField(3)
  completed,  // 已完成
}

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
  IdeaStatus status; // 新增：统一状态

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
    this.status = IdeaStatus.idea, // 默认是灵感状态
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
    IdeaStatus? status,
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
      status: status ?? this.status,
      projectId: projectId ?? this.projectId,
      recordingType: recordingType ?? this.recordingType,
    );
  }

  // 便捷属性：是否为灵感状态
  bool get isIdea => status == IdeaStatus.idea;

  // 便捷属性：是否为进行中状态（策划中或制作中）
  bool get isActive => status == IdeaStatus.planning || status == IdeaStatus.inProgress;

  // 便捷属性：是否已完成
  bool get isCompleted => status == IdeaStatus.completed;
}
