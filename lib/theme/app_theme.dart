import 'package:flutter/material.dart';

class AppTheme {
  // ═══════════════════════════════════════════════
  // 品牌色 - Cyan 青 (#0891B2)
  // ═══════════════════════════════════════════════
  static const Color accent = Color(0xFF0891B2);       // 品牌主色
  static const Color accentLight = Color(0xFF06B6D4);   // 品牌浅色
  static const Color accentLighter = Color(0xFF22D3EE); // 品牌更浅
  static const Color accentTint = Color(0xFFF0FDFA);    // 品牌极淡底色

  // 向后兼容
  static const Color primaryStart = accent;
  static const Color primaryEnd = accentLight;

  // ═══════════════════════════════════════════════
  // 中性色 - Slate 板岩灰
  // ═══════════════════════════════════════════════
  static const Color rockGrayLight = Color(0xFFF1F5F9);  // 浅岩灰背景
  static const Color rockGrayDark = Color(0xFF475569);    // 深岩灰

  // ═══════════════════════════════════════════════
  // 背景色
  // ═══════════════════════════════════════════════
  static const Color background = Color(0xFFF8FAFC);      // 极淡冷灰白
  static const Color surfaceColor = Colors.white;

  // ═══════════════════════════════════════════════
  // 文字颜色
  // ═══════════════════════════════════════════════
  static const Color textPrimary = Color(0xFF334155);     // 深板岩 - 标题/正文
  static const Color textSecondary = Color(0xFF64748B);   // 中板岩 - 次要文字
  static const Color textHint = Color(0xFF94A3B8);        // 浅板岩 - 提示文字
  static const Color textDisabled = Color(0xFFCBD5E1);    // 极浅 - 禁用文字

  // ═══════════════════════════════════════════════
  // 状态色 - 选题进度
  // ═══════════════════════════════════════════════
  static const Color statusPlanning = Color(0xFFF59E0B);   // 琥珀色 - 策划中
  static const Color statusInProgress = Color(0xFF3B82F6); // 蓝色 - 制作中
  static const Color statusCompleted = Color(0xFF10B981);  // 翡翠绿 - 已完成

  // ═══════════════════════════════════════════════
  // 功能色
  // ═══════════════════════════════════════════════
  static const Color divider = Color(0xFFE2E8F0);         // 分割线
  static const Color disabledBg = Color(0xFFE2E8F0);      // 禁用按钮背景
  static const Color danger = Color(0xFFEF4444);           // 危险/删除

  // 次要颜色 (向后兼容)
  static const Color secondary = Color(0xFF67E8F9);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(
        primary: accent,
        secondary: secondary,
        surface: surfaceColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
        ),
      ),
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: divider.withOpacity(0.3)),
        ),
        shadowColor: Colors.black,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: accent,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: rockGrayLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // 渐变色
  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [accent, accentLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get buttonGradient => const LinearGradient(
        colors: [accent, accentLight],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
}
