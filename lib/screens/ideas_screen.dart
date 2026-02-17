import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/idea_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/idea_card.dart';
import '../theme/app_theme.dart';
import 'idea_detail_screen.dart';
import 'capture_screen.dart';

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
                prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
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
                var ideas = ideaProvider.allIdeas;

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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 60,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '没有找到匹配的灵感',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CaptureScreen()),
          );
        },
        child: const Icon(Icons.add),
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (color ?? AppTheme.primaryStart)
                : (color ?? AppTheme.primaryStart).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : (color ?? AppTheme.primaryStart),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
