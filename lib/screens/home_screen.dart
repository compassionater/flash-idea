import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'capture_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // 光晕呼吸动画
  late AnimationController _glowController;
  late Animation<double> _glowOpacity;
  late Animation<double> _glowScale;

  // FAB 按压动画
  late AnimationController _fabController;
  late Animation<double> _fabScale;
  bool _isFabPressed = false;

  @override
  void initState() {
    super.initState();

    // 光晕：3秒周期脉动
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _glowOpacity = Tween<double>(begin: 0.25, end: 0.5).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _glowScale = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // FAB 弹性缩放
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _fabScale = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _onFabTapDown(TapDownDetails _) {
    _fabController.forward();
    HapticFeedback.lightImpact();
    setState(() => _isFabPressed = true);
  }

  void _onFabTapUp(TapUpDetails _) {
    _fabController.reverse();
    setState(() => _isFabPressed = false);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const CaptureScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _onFabTapCancel() {
    _fabController.reverse();
    setState(() => _isFabPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Layer 0: 空气渐变背景
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.background,
                  Colors.white,
                ],
              ),
            ),
          ),

          // Layer 1: 能量光晕 - 呼吸脉动
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Align(
                alignment: const Alignment(0.0, -0.15),
                child: Transform.scale(
                  scale: _glowScale.value,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
                    child: Container(
                      width: 220.0,
                      height: 220.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.accent.withOpacity(_glowOpacity.value),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Layer 2: 品牌标识
          Align(
            alignment: const Alignment(0.0, -0.45),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '灵感闪记',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary.withOpacity(0.15),
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '捕捉每一个灵光乍现',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textHint.withOpacity(0.5),
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Layer 3: FAB - 带按压缩放 + 触觉反馈
      floatingActionButton: AnimatedBuilder(
        animation: _fabScale,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabScale.value,
            child: child,
          );
        },
        child: GestureDetector(
          onTapDown: _onFabTapDown,
          onTapUp: _onFabTapUp,
          onTapCancel: _onFabTapCancel,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 72.0,
            height: 72.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accent.withOpacity(_isFabPressed ? 0.3 : 0.15),
                  blurRadius: _isFabPressed ? 32.0 : 24.0,
                  offset: const Offset(0, 8.0),
                  spreadRadius: _isFabPressed ? 4.0 : 0.0,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.add,
                size: 36.0,
                color: AppTheme.accent,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
