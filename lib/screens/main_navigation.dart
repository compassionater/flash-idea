import 'dart:ui';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'ideas_screen.dart';
import 'projects_screen.dart';
import 'categories_screen.dart';
import '../theme/app_theme.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    IdeasScreen(),
    ProjectsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 主页面内容
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(_currentIndex),
                child: _screens[_currentIndex],
              ),
            ),
          ),
          // 浮动底部导航栏
          Positioned(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 4),
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _NavItem(
                          index: 0,
                          icon: Icons.home_outlined,
                          activeIcon: Icons.home_rounded,
                          label: '首页',
                          isSelected: _currentIndex == 0,
                          onTap: () => setState(() => _currentIndex = 0),
                        ),
                        _NavItem(
                          index: 1,
                          icon: Icons.lightbulb_outlined,
                          activeIcon: Icons.lightbulb_rounded,
                          label: '灵感',
                          isSelected: _currentIndex == 1,
                          onTap: () => setState(() => _currentIndex = 1),
                        ),
                        _NavItem(
                          index: 2,
                          icon: Icons.folder_outlined,
                          activeIcon: Icons.folder_rounded,
                          label: '选题',
                          isSelected: _currentIndex == 2,
                          onTap: () => setState(() => _currentIndex = 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.accent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lightbulb,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '灵感闪记',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  '记录每一个灵感',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined, color: AppTheme.textPrimary),
            title: const Text('分类管理', style: TextStyle(color: AppTheme.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoriesScreen(),
                ),
              );
            },
          ),
          const Divider(color: AppTheme.divider),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppTheme.textPrimary),
            title: const Text('关于', style: TextStyle(color: AppTheme.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: '灵感闪记',
                applicationVersion: '1.3.7',
                applicationLegalese: '© 2024 FlashIdea',
                children: [
                  const SizedBox(height: 16),
                  const Text('快速捕捉、转瞬即逝的灵感'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 独立的导航项组件，自带弹簧缩放动画
class _NavItem extends StatefulWidget {
  final int index;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack), // 更优雅的弹簧
    );
  }

  @override
  void didUpdateWidget(covariant _NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        // 固定高度和宽度，防止跳动
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.isSelected ? _scaleAnimation.value : 1.0,
                  child: child,
                );
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Icon(
                  widget.isSelected ? widget.activeIcon : widget.icon,
                  key: ValueKey(widget.isSelected ? 'selected' : 'unselected'),
                  color: widget.isSelected ? AppTheme.accent : AppTheme.textSecondary,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              style: TextStyle(
                color: widget.isSelected ? AppTheme.accent : AppTheme.textSecondary,
                fontSize: 12,
                fontFamily: 'Roboto', // 指定字体防止宽度跳动
                fontWeight: FontWeight.w500, // 统一字重，仅改变颜色
              ),
              child: Text(widget.label),
            ),
          ],
        ),
      ),
    );
  }
}
