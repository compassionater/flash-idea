import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FloatingRecordButton extends StatefulWidget {
  final VoidCallback onPressed;

  const FloatingRecordButton({super.key, required this.onPressed});

  @override
  State<FloatingRecordButton> createState() => _FloatingRecordButtonState();
}

class _FloatingRecordButtonState extends State<FloatingRecordButton>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _glowAnimation;

  late AnimationController _morphController;
  late Animation<double> _morphAnimation;

  late AnimationController _clickController;
  late Animation<double> _clickScaleAnimation;

  // 深灰黑色
  static const Color buttonColor = Color(0xFF121212);
  // 青色 Teal
  static const Color tealGlow = Color(0xFF26A69A);

  @override
  void initState() {
    super.initState();

    // 呼吸动画 - 3秒周期
    _breathingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.5).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // 液态变形动画
    _morphController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _morphAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _morphController, curve: Curves.easeInOut),
    );

    // 点击反馈动画
    _clickController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _clickScaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _clickController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _morphController.dispose();
    _clickController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    HapticFeedback.lightImpact();
    _clickController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _clickController.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    _clickController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _breathingController,
          _morphController,
          _clickController,
        ]),
        builder: (context, child) {
          final breathScale = _breathingAnimation.value;
          final clickScale = _clickScaleAnimation.value;
          final morphValue = _morphAnimation.value;

          // 液态变形 - 轻微的不规则圆角
          final borderRadius = BorderRadius.circular(
            40 + (morphValue * 5 - 2.5),
          );

          return Transform.scale(
            scale: breathScale * clickScale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 外层液态光晕
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: borderRadius,
                    boxShadow: [
                      BoxShadow(
                        color: tealGlow.withOpacity(
                          _glowAnimation.value * 0.5,
                        ),
                        blurRadius: 25 + (morphValue * 10),
                        spreadRadius: 5 + (morphValue * 5),
                      ),
                    ],
                  ),
                ),
                // 主体按钮 - 深灰黑色液态
                AnimatedContainer(
                  duration: const Duration(milliseconds: 50),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(
                      40 + (morphValue * 3 - 1.5),
                    ),
                    color: buttonColor,
                    boxShadow: [
                      BoxShadow(
                        color: tealGlow.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
