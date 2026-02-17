import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/idea_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/floating_record_button.dart';
import '../widgets/idea_card.dart';
import '../theme/app_theme.dart';
import 'capture_screen.dart';
import 'idea_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IdeaProvider>().loadIdeas();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: const Text(
          '灵感闪记',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        titleSpacing: 20,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 灵感列表
            Expanded(
              child: Consumer2<IdeaProvider, CategoryProvider>(
                builder: (context, ideaProvider, categoryProvider, _) {
                  final ideas = ideaProvider.allIdeas;

                  if (ideas.isEmpty) {
                    // 空状态 - 只显示一个简洁的灯泡图标
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 60,
                            color: AppTheme.textSecondary,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 120),
                    itemCount: ideas.length,
                    itemBuilder: (context, index) {
                      final idea = ideas[index];
                      final category = categoryProvider.getCategoryById(idea.category);

                      return IdeaCard(
                        idea: idea,
                        category: category,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IdeaDetailScreen(ideaId: idea.id),
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
      ),
      floatingActionButton: FloatingRecordButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CaptureScreen()),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
