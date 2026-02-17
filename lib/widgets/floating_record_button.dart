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

  late AnimationController _clickController;
  late Animation<double> _clickScaleAnimation;
  late Animation<double> _clickGlowAnimation;

  // 深灰黑色
  static const Color buttonColor = Color(0xFF121212);
  // 竹子幽光 - 青色
  static const Color bambooGlow = Color(0xFF00D4FF);

  @override
  void initState() {
    super.initState();

    // 呼吸动画 - 3秒周期，1.0→1.05
    _breathingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // 光晕动画 - 透明度变化
    _glowAnimation = Tween<double>(begin: 0.2, end: 0.5).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // 点击反馈动画 - 使用弹性曲线让动画更自然
    _clickController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _clickScaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _clickController, curve: Curves.easeOutCubic),
    );

    _clickGlowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _clickController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
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
        animation: Listenable.merge([_breathingController, _clickController]),
        builder: (context, child) {
          // 呼吸动画基础缩放
          final breathScale = _breathingAnimation.value;
          // 点击缩放
          final clickScale = _clickScaleAnimation.value;

          return Transform.scale(
            scale: breathScale * clickScale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 外层青色光晕 - 呼吸 + 点击效果
                AnimatedContainer(
                  duration: const Duration(milliseconds: 50),
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: bambooGlow.withOpacity(
                          _glowAnimation.value * 0.5 + _clickGlowAnimation.value * 0.3,
                        ),
                        blurRadius: 30 + _clickGlowAnimation.value * 20,
                        spreadRadius: 10 + _clickGlowAnimation.value * 5,
                      ),
                    ],
                  ),
                ),
                // 主体按钮 - 深灰黑色
                AnimatedContainer(
                  duration: const Duration(milliseconds: 50),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.lerp(
                      buttonColor,
                      bambooGlow,
                      _clickGlowAnimation.value * 0.3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: bambooGlow.withOpacity(0.3),
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
