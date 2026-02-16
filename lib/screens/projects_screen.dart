import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/project_provider.dart';
import '../theme/app_theme.dart';
import 'project_detail_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选题'),
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, _) {
          final projects = provider.allProjects;

          if (projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '还没有选题',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '将灵感转为选题来开始跟踪',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
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
                      count: provider.allProjects.length,
                      isSelected: provider.selectedStatus == null,
                      onTap: () => provider.setSelectedStatus(null),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(
                      label: '待开始',
                      count: provider.todoCount,
                      isSelected: provider.selectedStatus == 'todo',
                      onTap: () => provider.setSelectedStatus('todo'),
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(
                      label: '进行中',
                      count: provider.inProgressCount,
                      isSelected: provider.selectedStatus == 'in_progress',
                      onTap: () => provider.setSelectedStatus('in_progress'),
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(
                      label: '已完成',
                      count: provider.completedCount,
                      isSelected: provider.selectedStatus == 'completed',
                      onTap: () => provider.setSelectedStatus('completed'),
                      color: Colors.green,
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
                    final project = projects[index];
                    return _buildProjectCard(project);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProjectDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppTheme.primaryStart)
              : (color ?? AppTheme.primaryStart).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : (color ?? AppTheme.primaryStart),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                color: isSelected ? Colors.white70 : (color ?? AppTheme.primaryStart),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(project) {
    final dateFormat = DateFormat('MM/dd');

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (project.status) {
      case 'in_progress':
        statusColor = Colors.blue;
        statusText = '进行中';
        statusIcon = Icons.play_circle_outline;
        break;
      case 'completed':
        statusColor = Colors.green;
        statusText = '已完成';
        statusIcon = Icons.check_circle_outline;
        break;
      default:
        statusColor = Colors.grey;
        statusText = '待开始';
        statusIcon = Icons.radio_button_unchecked;
    }

    Color recordingColor;
    String recordingText;
    switch (project.recordingStatus) {
      case 'recording':
        recordingColor = Colors.orange;
        recordingText = '拍摄中';
        break;
      case 'recorded':
        recordingColor = Colors.green;
        recordingText = '已拍摄';
        break;
      default:
        recordingColor = Colors.grey;
        recordingText = '未拍摄';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectDetailScreen(projectId: project.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
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
              if (project.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  project.description,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.videocam_outlined, size: 16, color: recordingColor),
                  const SizedBox(width: 4),
                  Text(
                    recordingText,
                    style: TextStyle(
                      color: recordingColor,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    dateFormat.format(project.updatedAt),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddProjectDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建选题'),
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
                labelText: '描述',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                await context.read<ProjectProvider>().addProject(
                      title: titleController.text,
                      description: descController.text,
                    );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }
}
