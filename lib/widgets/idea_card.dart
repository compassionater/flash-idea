import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/idea.dart';
import '../models/category.dart' as models;
import '../theme/app_theme.dart';

class IdeaCard extends StatelessWidget {
  final Idea idea;
  final models.Category? category;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const IdeaCard({
    super.key,
    required this.idea,
    this.category,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MM/dd HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 分类标签
                  if (category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(category!.colorValue).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category!.name,
                        style: TextStyle(
                          color: Color(category!.colorValue),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const Spacer(),
                  // 类型图标
                  _buildTypeIcon(),
                  const SizedBox(width: 8),
                  // 日期
                  Text(
                    dateFormat.format(idea.createdAt),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 标题
              if (idea.title.isNotEmpty)
                Text(
                  idea.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (idea.title.isNotEmpty) const SizedBox(height: 8),
              // 内容
              Text(
                idea.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // 预览图
              if (idea.imagePath != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    idea.imagePath!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.image, size: 40, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
              ],
              // 项目标记
              if (idea.isProject) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryStart.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder_outlined, size: 14, color: AppTheme.primaryStart),
                      SizedBox(width: 4),
                      Text(
                        '已转为选题',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryStart,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    IconData icon;
    Color color;

    switch (idea.recordingType) {
      case 'image':
        icon = Icons.image_outlined;
        color = Colors.green;
        break;
      case 'audio':
        icon = Icons.mic_outlined;
        color = Colors.orange;
        break;
      default:
        icon = Icons.edit_outlined;
        color = AppTheme.primaryStart;
    }

    return Icon(icon, size: 18, color: color);
  }
}
