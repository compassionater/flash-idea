import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FloatingMemoryBubble extends StatefulWidget {
  final String text;
  final Duration delay; // 可选：启动延迟

  const FloatingMemoryBubble({
    super.key,
    required this.text,
    this.delay = Duration.zero,
  });

  @override
  State<FloatingMemoryBubble> createState() => _FloatingMemoryBubbleState();
}

class _FloatingMemoryBubbleState extends State<FloatingMemoryBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    // 透明度: 0 -> 0.6 -> 0
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.6)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20, // 前 20% 时间进入
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.6),
        weight: 40, // 中间 40% 时间保持
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.6, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40, // 后 40% 时间淡出
      ),
    ]).animate(_controller);

    // 位移: 向上漂浮 (Offset(0, 0.1) -> Offset(0, -0.1))
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: const Offset(0, -0.1),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // 启动动画 (支持延迟)
    if (widget.delay == Duration.zero) {
      _controller.forward(); // 运行一次
      // 如果需要循环，可以使用 repeat() 或监听状态
      _controller.repeat(reverse: false); 
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
           // _controller.forward();
           _controller.repeat(); 
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        // 性能优化：使用 RepaintBoundary 缓存复杂绘制（阴影/圆角），避免每帧重绘
        child: RepaintBoundary(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5), // Pure white background, semi-transparent
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              widget.text,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
