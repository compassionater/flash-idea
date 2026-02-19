// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'idea.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IdeaAdapter extends TypeAdapter<Idea> {
  @override
  final int typeId = 0;

  @override
  Idea read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    // 数据迁移：兼容旧版本 (旧版本 isProject 是 bool，新版本 status 是 IdeaStatus)
    IdeaStatus status;
    if (fields[7] is bool) {
      // 旧版本数据：isProject bool -> 转换为 status
      final isProject = fields[7] as bool;
      status = isProject ? IdeaStatus.planning : IdeaStatus.idea;
    } else {
      // 新版本数据
      status = fields[7] as IdeaStatus;
    }

    return Idea(
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String,
      imagePath: fields[3] as String?,
      audioPath: fields[4] as String?,
      category: fields[5] as String,
      createdAt: fields[6] as DateTime,
      status: status,
      projectId: fields[8] as String?,
      recordingType: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Idea obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.audioPath)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.projectId)
      ..writeByte(9)
      ..write(obj.recordingType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdeaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IdeaStatusAdapter extends TypeAdapter<IdeaStatus> {
  @override
  final int typeId = 3;

  @override
  IdeaStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return IdeaStatus.idea;
      case 1:
        return IdeaStatus.planning;
      case 2:
        return IdeaStatus.inProgress;
      case 3:
        return IdeaStatus.completed;
      default:
        return IdeaStatus.idea;
    }
  }

  @override
  void write(BinaryWriter writer, IdeaStatus obj) {
    switch (obj) {
      case IdeaStatus.idea:
        writer.writeByte(0);
        break;
      case IdeaStatus.planning:
        writer.writeByte(1);
        break;
      case IdeaStatus.inProgress:
        writer.writeByte(2);
        break;
      case IdeaStatus.completed:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdeaStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
