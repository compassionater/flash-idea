import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../theme/app_theme.dart';

class ProjectDetailScreen extends StatelessWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, provider, _) {
        final project = provider.allProjects.firstWhere(
          (p) => p.id == projectId,
          orElse: () => throw Exception('选题不存在'),
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('选题详情'),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('确认删除'),
                        content: const Text('确定要删除这个选题吗？'),
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
                      await provider.deleteProject(project.id);
                      if (context.mounted) Navigator.pop(context);
                    }
                  }
                },
                itemBuilder: (context) => [
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
                // 标题
                Text(
                  project.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // 描述
                if (project.description.isNotEmpty)
                  Text(
                    project.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                const SizedBox(height: 32),

                // 选题状态
                const Text(
                  '选题状态',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatusButton(
                      context: context,
                      label: '待开始',
                      value: 'todo',
                      currentStatus: project.status,
                      color: Colors.grey,
                      provider: provider,
                      projectId: projectId,
                    ),
                    const SizedBox(width: 12),
                    _buildStatusButton(
                      context: context,
                      label: '进行中',
                      value: 'in_progress',
                      currentStatus: project.status,
                      color: Colors.blue,
                      provider: provider,
                      projectId: projectId,
                    ),
                    const SizedBox(width: 12),
                    _buildStatusButton(
                      context: context,
                      label: '已完成',
                      value: 'completed',
                      currentStatus: project.status,
                      color: Colors.green,
                      provider: provider,
                      projectId: projectId,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 拍摄状态
                const Text(
                  '拍摄状态',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildRecordingButton(
                      context: context,
                      label: '未开始',
                      value: 'not_started',
                      currentStatus: project.recordingStatus,
                      color: Colors.grey,
                      provider: provider,
                      projectId: projectId,
                    ),
                    const SizedBox(width: 12),
                    _buildRecordingButton(
                      context: context,
                      label: '拍摄中',
                      value: 'recording',
                      currentStatus: project.recordingStatus,
                      color: Colors.orange,
                      provider: provider,
                      projectId: projectId,
                    ),
                    const SizedBox(width: 12),
                    _buildRecordingButton(
                      context: context,
                      label: '已拍摄',
                      value: 'recorded',
                      currentStatus: project.recordingStatus,
                      color: Colors.green,
                      provider: provider,
                      projectId: projectId,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 关联灵感
                const Text(
                  '关联灵感',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                if (project.ideaIds.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Colors.grey),
                        SizedBox(width: 12),
                        Text(
                          '暂无关联灵感',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  )
                else
                  Text('${project.ideaIds.length} 个灵感'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusButton({
    required BuildContext context,
    required String label,
    required String value,
    required String currentStatus,
    required Color color,
    required ProjectProvider provider,
    required String projectId,
  }) {
    final isSelected = currentStatus == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => provider.updateProjectStatus(projectId, value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingButton({
    required BuildContext context,
    required String label,
    required String value,
    required String currentStatus,
    required Color color,
    required ProjectProvider provider,
    required String projectId,
  }) {
    final isSelected = currentStatus == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => provider.updateRecordingStatus(projectId, value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
