import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/idea_provider.dart';
import '../providers/project_provider.dart';
import '../providers/category_provider.dart';
import '../models/idea.dart';
import '../theme/app_theme.dart';

class IdeaDetailScreen extends StatelessWidget {
  final String ideaId;

  const IdeaDetailScreen({super.key, required this.ideaId});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy年MM月dd日 HH:mm');

    return Consumer2<IdeaProvider, CategoryProvider>(
      builder: (context, ideaProvider, categoryProvider, _) {
        final idea = ideaProvider.allIdeas.firstWhere(
          (i) => i.id == ideaId,
          orElse: () => Idea(
            id: '',
            title: '',
            content: '',
            category: '',
            createdAt: DateTime.now(),
          ),
        );

        if (idea.id.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('灵感不存在')),
          );
        }

        final category = categoryProvider.getCategoryById(idea.category);

        return Scaffold(
          appBar: AppBar(
            title: const Text('灵感详情'),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('确认删除'),
                        content: const Text('确定要删除这条灵感吗？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('删除'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      await ideaProvider.deleteIdea(idea.id);
                      if (context.mounted) Navigator.pop(context);
                    }
                  } else if (value == 'convert') {
                    if (!idea.isProject) {
                      await _showConvertToProjectDialog(context, idea);
                    }
                  }
                },
                itemBuilder: (context) => [
                  if (!idea.isProject)
                    const PopupMenuItem(
                      value: 'convert',
                      child: Row(
                        children: [
                          Icon(Icons.folder_outlined),
                          SizedBox(width: 8),
                          Text('转为选题'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Text('删除', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 分类和时间
                Row(
                  children: [
                    if (category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Color(category.colorValue).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          category.name,
                          style: TextStyle(
                            color: Color(category.colorValue),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      dateFormat.format(idea.createdAt),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 标题
                if (idea.title.isNotEmpty)
                  Text(
                    idea.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                if (idea.title.isNotEmpty) const SizedBox(height: 16),

                // 内容
                Text(
                  idea.content,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),

                // 图片
                if (idea.imagePath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(idea.imagePath!),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.image, size: 60, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),

                // 选题标记
                if (idea.isProject) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryStart.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.folder, color: AppTheme.primaryStart),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '已转为选题',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryStart,
                                ),
                              ),
                              Text(
                                '此灵感已被添加到选题中',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showConvertToProjectDialog(BuildContext context, Idea idea) async {
    final titleController = TextEditingController(text: idea.title);
    final descController = TextEditingController(text: idea.content);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('转为选题'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '选题标题',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: '选题描述',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      // 创建选题
      await context.read<ProjectProvider>().addProject(
            title: titleController.text,
            description: descController.text,
            ideaIds: [idea.id],
          );

      // 更新灵感
      await context.read<IdeaProvider>().convertToProject(idea.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已转为选题')),
        );
      }
    }
  }
}
