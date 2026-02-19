import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class LiquidRecordButton extends StatefulWidget {
  final VoidCallback onPressed;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;

  const LiquidRecordButton({
    super.key,
    required this.onPressed,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });

  @override
  State<LiquidRecordButton> createState() => _LiquidRecordButtonState();
}

class _LiquidRecordButtonState extends State<LiquidRecordButton>
    with TickerProviderStateMixin {
  late AnimationController _morphController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _morphAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // 液态变形动画 - 不规则形状变化
    _morphController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _morphAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _morphController, curve: Curves.easeInOut),
    );

    // 缓慢脉动
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 光晕动画
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _morphController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
    widget.onLongPressStart();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    HapticFeedback.lightImpact();
    widget.onLongPressEnd();
    widget.onPressed();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    widget.onLongPressEnd();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = screenWidth * 0.55;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([_morphController, _pulseController, _glowController]),
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? 0.92 : _pulseAnimation.value,
            child: SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 外层液态光晕
                  _buildLiquidGlow(buttonSize, _isPressed),
                  // 液态主体
                  _buildLiquidBody(buttonSize, _isPressed),
                  // 中心图标
                  _buildCenterIcon(_isPressed),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiquidGlow(double size, bool isPressed) {
    final glowColor = isPressed
        ? const Color(0xFFFFFFFF)
        : AppTheme.accent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size * (_isPressed ? 1.1 : 1.0),
      height: size * (_isPressed ? 1.1 : 1.0),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(size * (_isPressed ? 0.4 : 0.35)),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(_isPressed ? 0.6 : _glowAnimation.value * 0.4),
            blurRadius: _isPressed ? 60 : 40,
            spreadRadius: _isPressed ? 20 : 10,
          ),
        ],
      ),
    );
  }

  Widget _buildLiquidBody(double size, bool isPressed) {
    // 液态变形效果
    final borderRadius = BorderRadius.circular(
      size * (0.3 + _morphAnimation.value * 0.1),
    );

    // 颜色：从灰到青色
    final Color bodyColor;
    final Color shadowColor;

    if (isPressed) {
      bodyColor = const Color(0xFFFFFFFF);
      shadowColor = AppTheme.accentLighter;
    } else {
      bodyColor = Color.lerp(
        AppTheme.rockGrayDark,   // 板岩灰
        AppTheme.accent,         // 哑光青
        _morphAnimation.value,
      )!;
      shadowColor = AppTheme.accent;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPressed
              ? [const Color(0xFFFFFFFF), AppTheme.accentTint]
              : [
                  Color.lerp(
                    AppTheme.rockGrayDark,
                    AppTheme.accentLight,
                    _morphAnimation.value,
                  )!,
                  Color.lerp(
                    AppTheme.textSecondary,
                    AppTheme.accent,
                    _morphAnimation.value,
                  )!,
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: CustomPaint(
          size: Size(size, size),
          painter: LiquidPainter(
            morphValue: _morphAnimation.value,
            isPressed: isPressed,
          ),
        ),
      ),
    );
  }

  Widget _buildCenterIcon(bool isPressed) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      child: Icon(
        Icons.add_rounded,
        color: isPressed ? AppTheme.accent : Colors.white,
        size: 64,
      ),
    );
  }
}

/// 液态效果CustomPainter
class LiquidPainter extends CustomPainter {
  final double morphValue;
  final bool isPressed;

  LiquidPainter({required this.morphValue, required this.isPressed});

  @override
  void paint(Canvas canvas, Size size) {
    if (isPressed) return;

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // 绘制多个圆形模拟液态融合效果
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final baseRadius = size.width * 0.15;

    // 动态偏移量
    final offset1 = morphValue * size.width * 0.1;
    final offset2 = (1 - morphValue) * size.width * 0.1;

    canvas.drawCircle(
      Offset(centerX - offset1, centerY - offset2),
      baseRadius,
      paint,
    );

    canvas.drawCircle(
      Offset(centerX + offset2, centerY + offset1),
      baseRadius * 0.8,
      paint,
    );

    canvas.drawCircle(
      Offset(centerX + offset1 * 0.5, centerY - offset1),
      baseRadius * 0.6,
      paint,
    );
  }

  @override
  bool shouldRepaint(LiquidPainter oldDelegate) {
    return oldDelegate.morphValue != morphValue || oldDelegate.isPressed != isPressed;
  }
}
