import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/idea_provider.dart';

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
              // 编辑按钮
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _showEditDialog(context, idea),
              ),
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
                  } else if (value == 'start') {
                    if (idea.status == IdeaStatus.idea) {
                      await _startPlanning(context, idea);
                    }
                  }
                },
                itemBuilder: (context) => [
                  if (idea.status == IdeaStatus.idea)
                    const PopupMenuItem(
                      value: 'start',
                      child: Row(
                        children: [
                          Icon(Icons.play_arrow_outlined),
                          SizedBox(width: 8),
                          Text('开始策划'),
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
                          color: AppTheme.rockGrayLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          category.name,
                          style: const TextStyle(
                            color: AppTheme.rockGrayDark,
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

                // 状态显示 - 非灵感状态显示状态进度条
                if (idea.status != IdeaStatus.idea) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              idea.status == IdeaStatus.completed
                                  ? Icons.check_circle
                                  : Icons.folder,
                              color: AppTheme.accent,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getStatusLabel(idea.status),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // 状态步骤条
                        Row(
                          children: [
                            _buildStatusDot(IdeaStatus.idea, idea.status),
                            _buildStatusLine(idea.status, IdeaStatus.planning),
                            _buildStatusDot(IdeaStatus.planning, idea.status),
                            _buildStatusLine(idea.status, IdeaStatus.inProgress),
                            _buildStatusDot(IdeaStatus.inProgress, idea.status),
                            _buildStatusLine(idea.status, IdeaStatus.completed),
                            _buildStatusDot(IdeaStatus.completed, idea.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // 状态标签
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('灵感', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                            Text('策划中', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                            Text('制作中', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                            Text('已完成', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 状态更新按钮
                        if (idea.status != IdeaStatus.completed)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => _showStatusUpdateDialog(context, idea),
                              child: const Text('更新状态'),
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

  Future<void> _showEditDialog(BuildContext context, Idea idea) async {
    final titleController = TextEditingController(text: idea.title);
    final contentController = TextEditingController(text: idea.content);
    String selectedCategory = idea.category;

    // 获取分类列表
    final categoryProvider = context.read<CategoryProvider>();
    final categories = categoryProvider.categories;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('编辑灵感'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '标题',
                    hintText: '请输入标题',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: '内容',
                    hintText: '请输入内容',
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                // 分类选择
                const Text('分类', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: categories.map((cat) {
                    final isSelected = cat.id == selectedCategory;
                    return ChoiceChip(
                      label: Text(cat.name),
                      selected: isSelected,
                      selectedColor: AppTheme.accent.withOpacity(0.2),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => selectedCategory = cat.id);
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final provider = context.read<IdeaProvider>();
      // 使用copyWith更新灵感
      final updatedIdea = idea.copyWith(
        title: titleController.text,
        content: contentController.text,
        category: selectedCategory,
      );
      await provider.updateIdea(updatedIdea);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('灵感已更新')),
        );
      }
    }
  }

  Future<void> _startPlanning(BuildContext context, Idea idea) async {
    // 直接将灵感状态改为策划中，灵感就是项目
    await context.read<IdeaProvider>().updateIdeaStatus(idea.id, IdeaStatus.planning);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已开始策划')),
      );
    }
  }

  // 获取状态标签
  String _getStatusLabel(IdeaStatus status) {
    switch (status) {
      case IdeaStatus.idea:
        return '灵感';
      case IdeaStatus.planning:
        return '策划中';
      case IdeaStatus.inProgress:
        return '制作中';
      case IdeaStatus.completed:
        return '已完成';
    }
  }

  // 构建状态圆点
  Widget _buildStatusDot(IdeaStatus status, IdeaStatus currentStatus) {
    final isActive = status.index <= currentStatus.index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      width: isActive ? 14 : 12,
      height: isActive ? 14 : 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppTheme.accent : AppTheme.rockGrayLight,
        border: Border.all(
          color: isActive ? AppTheme.accent : AppTheme.rockGrayLight,
          width: 2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppTheme.accent.withOpacity(0.3),
                  blurRadius: 6,
                  spreadRadius: 1,
                )
              ]
            : [],
      ),
    );
  }

  // 构建状态连接线
  Widget _buildStatusLine(IdeaStatus currentStatus, IdeaStatus nextStatus) {
    final isActive = currentStatus.index >= nextStatus.index;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        height: isActive ? 3 : 2,
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accent : AppTheme.rockGrayLight,
          borderRadius: BorderRadius.circular(1.5),
        ),
      ),
    );
  }

  // 显示状态更新对话框
  Future<void> _showStatusUpdateDialog(BuildContext context, Idea idea) async {
    final result = await showDialog<IdeaStatus>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('更新状态'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: IdeaStatus.values.map((status) {
            return RadioListTile<IdeaStatus>(
              title: Text(_getStatusLabel(status)),
              value: status,
              groupValue: idea.status,
              onChanged: (value) {
                Navigator.pop(context, value);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );

    if (result != null && context.mounted) {
      await context.read<IdeaProvider>().updateIdeaStatus(idea.id, result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('状态已更新为: ${_getStatusLabel(result)}')),
        );
      }
    }
  }
}
