import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/idea_provider.dart';
import '../providers/category_provider.dart';
import '../models/idea.dart';
import '../theme/app_theme.dart';
import 'idea_detail_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IdeaProvider>().loadIdeas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选题'),
      ),
      body: Consumer2<IdeaProvider, CategoryProvider>(
        builder: (context, ideaProvider, categoryProvider, _) {
          // 筛选：只显示非灵感状态的灵感（策划中/制作中/已完成）
          var projects = ideaProvider.allIdeas
              .where((idea) => idea.status != IdeaStatus.idea)
              .toList();

          // 状态筛选
          if (_selectedStatus != null) {
            projects = projects
                .where((idea) => idea.status.name == _selectedStatus)
                .toList();
          }

          if (projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.folder_outlined,
                    size: 80,
                    color: AppTheme.textDisabled,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '还没有选题',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.textHint,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '在灵感详情页点击"开始策划"来创建选题',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textHint,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // 状态筛选
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildStatusChip(
                      label: '全部',
                      count: ideaProvider.allIdeas
                          .where((i) => i.status != IdeaStatus.idea)
                          .length,
                      isSelected: _selectedStatus == null,
                      onTap: () => setState(() => _selectedStatus = null),
                      color: AppTheme.accent,
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(
                      label: '策划中',
                      count: ideaProvider.allIdeas
                          .where((i) => i.status == IdeaStatus.planning)
                          .length,
                      isSelected: _selectedStatus == 'planning',
                      onTap: () => setState(() => _selectedStatus = 'planning'),
                      color: AppTheme.statusPlanning,
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(
                      label: '制作中',
                      count: ideaProvider.allIdeas
                          .where((i) => i.status == IdeaStatus.inProgress)
                          .length,
                      isSelected: _selectedStatus == 'inProgress',
                      onTap: () => setState(() => _selectedStatus = 'inProgress'),
                      color: AppTheme.statusInProgress,
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(
                      label: '已完成',
                      count: ideaProvider.allIdeas
                          .where((i) => i.status == IdeaStatus.completed)
                          .length,
                      isSelected: _selectedStatus == 'completed',
                      onTap: () => setState(() => _selectedStatus = 'completed'),
                      color: AppTheme.statusCompleted,
                    ),
                  ],
                ),
              ),
              // 列表
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final idea = projects[index];
                    return _buildProjectCard(idea, categoryProvider);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                color: isSelected ? Colors.white70 : color,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(Idea idea, CategoryProvider categoryProvider) {
    final dateFormat = DateFormat('MM/dd');

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (idea.status) {
      case IdeaStatus.planning:
        statusColor = AppTheme.statusPlanning;
        statusText = '策划中';
        statusIcon = Icons.edit_calendar_outlined;
        break;
      case IdeaStatus.inProgress:
        statusColor = AppTheme.statusInProgress;
        statusText = '制作中';
        statusIcon = Icons.play_circle_outline;
        break;
      case IdeaStatus.completed:
        statusColor = AppTheme.statusCompleted;
        statusText = '已完成';
        statusIcon = Icons.check_circle_outline;
        break;
      default:
        statusColor = Colors.grey;
        statusText = '灵感';
        statusIcon = Icons.lightbulb_outline;
    }

    final category = categoryProvider.getCategoryById(idea.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.divider.withOpacity(0.3),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IdeaDetailScreen(ideaId: idea.id),
              ),
            );
          },
          child: Stack(
            children: [
              // 左上角分类色彩小圆
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: category != null
                        ? Color(category.colorValue)
                        : statusColor,
                    shape: BoxShape.circle,
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
                        // 分类标签
                        if (category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(category.colorValue)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(category.colorValue),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        const Spacer(),
                        // 状态标签
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon,
                                  size: 14, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      idea.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (idea.content.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        idea.content,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      dateFormat.format(idea.createdAt),
                      style: const TextStyle(
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
      ),
    );
  }
}
