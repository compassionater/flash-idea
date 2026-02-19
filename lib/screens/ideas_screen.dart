import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/idea_provider.dart';
import '../providers/category_provider.dart';
import '../models/idea.dart';
import '../widgets/idea_card.dart';
import '../theme/app_theme.dart';
import 'idea_detail_screen.dart';

class IdeasScreen extends StatefulWidget {
  const IdeasScreen({super.key});

  @override
  State<IdeasScreen> createState() => _IdeasScreenState();
}

class _IdeasScreenState extends State<IdeasScreen> {
  String? _selectedCategoryId;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IdeaProvider>().loadIdeas();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('灵感列表'),
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索灵感...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // 分类筛选
          SizedBox(
            height: 40,
            child: Consumer<CategoryProvider>(
              builder: (context, provider, _) {
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildCategoryChip(
                      label: '全部',
                      isSelected: _selectedCategoryId == null,
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = null;
                        });
                      },
                    ),
                    ...provider.categories.map((category) {
                      return _buildCategoryChip(
                        label: category.name,
                        color: Color(category.colorValue),
                        isSelected: _selectedCategoryId == category.id,
                        onTap: () {
                          setState(() {
                            _selectedCategoryId = category.id;
                          });
                        },
                      );
                    }),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // 灵感列表
          Expanded(
            child: Consumer2<IdeaProvider, CategoryProvider>(
              builder: (context, ideaProvider, categoryProvider, _) {
                // 只显示灵感状态的条目（已策划的不显示）
                var ideas = ideaProvider.allIdeas
                    .where((i) => i.status == IdeaStatus.idea)
                    .toList();

                // 分类筛选
                if (_selectedCategoryId != null) {
                  ideas = ideas
                      .where((i) => i.category == _selectedCategoryId)
                      .toList();
                }

                // 搜索筛选
                if (_searchQuery.isNotEmpty) {
                  final query = _searchQuery.toLowerCase();
                  ideas = ideas.where((i) {
                    return i.title.toLowerCase().contains(query) ||
                        i.content.toLowerCase().contains(query);
                  }).toList();
                }

                if (ideas.isEmpty) {
                  return _buildEmptyState();
                }

                return _StaggeredList(
                  itemCount: ideas.length,
                  itemBuilder: (context, index) {
                    final idea = ideas[index];
                    final category =
                        categoryProvider.getCategoryById(idea.category);

                    return IdeaCard(
                      idea: idea,
                      category: category,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                IdeaDetailScreen(ideaId: idea.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _BreathingIcon(
            icon: Icons.lightbulb_outlined,
            size: 64,
            color: AppTheme.textDisabled,
          ),
          const SizedBox(height: 20),
          const Text(
            '还没有灵感',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textHint,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '回到首页，点击 + 捕捉你的第一个灵感',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textDisabled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    Color? color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.accent
                : AppTheme.rockGrayLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.rockGrayDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// 交错动画列表
class _StaggeredList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const _StaggeredList({required this.itemCount, required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return _StaggeredItem(
          index: index,
          child: itemBuilder(context, index),
        );
      },
    );
  }
}

/// 单个交错动画项
class _StaggeredItem extends StatefulWidget {
  final int index;
  final Widget child;

  const _StaggeredItem({required this.index, required this.child});

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slideOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideOffset = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // 交错延迟：每个 item 延迟 60ms
    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: SlideTransition(
            position: _slideOffset,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// 呼吸缩放图标
class _BreathingIcon extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color color;

  const _BreathingIcon({
    required this.icon,
    required this.size,
    required this.color,
  });

  @override
  State<_BreathingIcon> createState() => _BreathingIconState();
}

class _BreathingIconState extends State<_BreathingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: Icon(
            widget.icon,
            size: widget.size,
            color: widget.color,
          ),
        );
      },
    );
  }
}
