import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/idea.dart';
import '../models/category.dart' as models;
import '../theme/app_theme.dart';
import '../providers/idea_provider.dart';
import '../providers/category_provider.dart';

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

  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '选择分类',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Consumer<CategoryProvider>(
                builder: (context, categoryProvider, child) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: categoryProvider.categories.map((cat) {
                      final isSelected = category?.id == cat.id;
                      return ChoiceChip(
                        label: Text(cat.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            context.read<IdeaProvider>().updateIdeaCategory(idea.id, cat.id);
                            Navigator.pop(context);
                          }
                        },
                        backgroundColor: AppTheme.background,
                        selectedColor: Color(cat.colorValue).withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: isSelected ? Color(cat.colorValue) : AppTheme.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MM/dd HH:mm');
    // Determine if it's "Uncategorized" (null, 'other', or 'uncategorized')
    final isUncategorized = category == null || 
                            category!.id == 'uncategorized' || 
                            category!.id == 'other';
    
    final categoryColor = !isUncategorized
        ? Color(category!.colorValue)
        : AppTheme.textHint;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.divider.withOpacity(0.3),
            width: 0.5,
          ),
          boxShadow: [
            // 近影 - 清晰度
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
            // 远影 - 深度感
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // 左上角分类色彩小圆 (可点击)
              Positioned(
                top: 0,
                left: 0,
                child: InkWell(
                   onTap: () => _showCategoryPicker(context),
                   borderRadius: const BorderRadius.only(
                     topLeft: Radius.circular(16),
                     bottomRight: Radius.circular(16),
                   ),
                   child: Padding(
                     padding: const EdgeInsets.all(12),
                     child: isUncategorized 
                       ? Container(
                           width: 12,
                           height: 12,
                           decoration: BoxDecoration(
                             shape: BoxShape.circle,
                             border: Border.all(
                               color: AppTheme.textHint.withOpacity(0.5),
                               width: 1.5,
                             ),
                           ),
                           // Optional: Add a tiny icon inside if needed, but simple circle is better for "empty"
                         )
                       : Container(
                           width: 10, // Slightly smaller filled circle
                           height: 10,
                           decoration: BoxDecoration(
                             color: categoryColor,
                             shape: BoxShape.circle,
                             boxShadow: [
                               BoxShadow(
                                 color: categoryColor.withOpacity(0.4),
                                 blurRadius: 4,
                                 spreadRadius: 1,
                               ),
                             ],
                           ),
                         ),
                   ),
                ),
              ),
              // 主内容
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // 分类标签 (已移除，功能合并到左上角小圆点)
                        // 若用户需要看到文字，可以在小圆点旁显示，但用户要求 "点击左上角分类"
                        // 我们只保留时间，或者在这里显示 "点击分类" 的提示文字 (仅当未分类时)
                        if (isUncategorized)
                          GestureDetector(
                            onTap: () => _showCategoryPicker(context),
                            child: Text(
                              '点击分类',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textHint.withOpacity(0.5),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        else
                           // 已分类则显示分类名称 (可选，或者保持简洁只显示颜色)
                           // 用户原话: "每个灵感左上角都有灵感分类的标签，所以我想用户点击这个就可以..."
                           // 之前的代码是在 Row 里显示 Category Name Chip。
                           // 我们保留这个 Chip 但让它也可以点击。
                          GestureDetector(
                            onTap: () => _showCategoryPicker(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                category!.name,
                                style: TextStyle(
                                  color: categoryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        
                        const Spacer(),
                        _buildTypeIcon(),
                        const SizedBox(width: 8),
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
                              color: AppTheme.rockGrayLight,
                              child: const Center(
                                child: Icon(Icons.image,
                                    size: 40, color: AppTheme.textHint),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    // 状态标记
                    if (idea.status != IdeaStatus.idea) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              idea.status == IdeaStatus.completed
                                  ? Icons.check_circle_outline
                                  : Icons.folder_outlined,
                              size: 14,
                              color: AppTheme.accent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              idea.status == IdeaStatus.planning
                                  ? '策划中'
                                  : idea.status == IdeaStatus.inProgress
                                      ? '制作中'
                                      : '已完成',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.accent,
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
        color = AppTheme.textSecondary;
        break;
      case 'audio':
        icon = Icons.mic_outlined;
        color = AppTheme.textSecondary;
        break;
      default:
        icon = Icons.edit_outlined;
        color = AppTheme.textSecondary;
    }

    return Icon(icon, size: 18, color: color);
  }
}
