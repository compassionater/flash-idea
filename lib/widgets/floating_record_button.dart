import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FloatingRecordButton extends StatefulWidget {
  final VoidCallback onPressed;

  const FloatingRecordButton({super.key, required this.onPressed});

  @override
  State<FloatingRecordButton> createState() => _FloatingRecordButtonState();
}

class _FloatingRecordButtonState extends State<FloatingRecordButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  // 品牌青色
  static const Color accentColor = Color(0xFF0891B2);
  // 哑光灰阴影
  static const Color shadowColor = Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    HapticFeedback.lightImpact();
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final isPressed = _controller.value;

          // 按下时阴影变深、更实
          final blurRadius = 30.0 - (isPressed * 15.0); // 30 -> 15
          final shadowOpacity = 0.2 + (isPressed * 0.15); // 0.2 -> 0.35
          final offsetY = 12.0 - (isPressed * 6.0); // 12 -> 6
          final spreadRadius = isPressed > 0.5 ? -5.0 : 0.0;

          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 72.0,
              height: 72.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withOpacity(shadowOpacity),
                    blurRadius: blurRadius,
                    spreadRadius: spreadRadius,
                    offset: Offset(0, offsetY),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: accentColor,
                size: 32.0,
              ),
            ),
          );
        },
      ),
    );
  }
}
