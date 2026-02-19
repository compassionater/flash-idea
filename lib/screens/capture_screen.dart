import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/idea_provider.dart';
import '../theme/app_theme.dart';

/// 无压输入页面 v1.3 - 沉浸式设计
class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final _contentController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isAnalyzing = false;
  bool _hasContent = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    setState(() {
      _hasContent = text.trim().isNotEmpty;
    });
  }

  Future<void> _saveIdea() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _isSaving = true;
    });

    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 1500));

    final title = content.length > 15 ? '${content.substring(0, 15)}...' : content;

    await context.read<IdeaProvider>().addIdea(
      title: title,
      content: content,
      category: 'uncategorized', // Post-Classification workflow
      recordingType: 'text',
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _startAIAnalysis() {
    if (_contentController.text.trim().isEmpty) return;

    setState(() {
      _isAnalyzing = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI分析功能开发中...')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 背景极光光晕
          Center(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
              child: Container(
                width: 320.0,
                height: 320.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accent.withOpacity(0.15),
                ),
              ),
            ),
          ),

          // 主内容层
          SafeArea(
            child: Column(
              children: [
                // 顶部关闭按钮
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: const Icon(
                            Icons.close,
                            color: AppTheme.textHint,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 输入区域 - 极光毛玻璃
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24.0),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FAFB).withOpacity(0.85),
                            borderRadius: BorderRadius.circular(24.0),
                            border: Border.all(
                              color: AppTheme.accent.withOpacity(0.08),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accent.withOpacity(0.06),
                                blurRadius: 24,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Material(
                              color: Colors.transparent,
                              child: TextField(
                                controller: _contentController,
                                focusNode: _focusNode,
                                onChanged: _onTextChanged,
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                decoration: const InputDecoration(
                                  hintText: '又有新想法了！',
                                  hintStyle: TextStyle(
                                    color: AppTheme.textDisabled,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                ),
                                style: const TextStyle(
                                  fontSize: 18,
                                  height: 1.5,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 底部操作栏
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: _hasContent && !_isAnalyzing ? _startAIAnalysis : null,
                        icon: Icon(
                          Icons.bolt,
                          color: _hasContent
                              ? AppTheme.textHint
                              : AppTheme.textDisabled,
                          size: 20,
                        ),
                        label: Text(
                          _isAnalyzing ? '思考中...' : 'AI分析',
                          style: TextStyle(
                            color: _hasContent
                                ? AppTheme.textHint
                                : AppTheme.textDisabled,
                          ),
                        ),
                      ),
                      FloatingActionButton(
                        mini: true,
                        elevation: 2.0,
                        backgroundColor: _hasContent
                            ? AppTheme.accent
                            : AppTheme.disabledBg,
                        onPressed: _hasContent ? _saveIdea : null,
                        child: Icon(
                          Icons.arrow_upward,
                          color: _hasContent ? Colors.white : AppTheme.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 保存时的发酵动画 - 始终保留在 widget tree 中以便动画生效
          IgnorePointer(
            ignoring: !_isSaving,
            child: AnimatedOpacity(
              opacity: _isSaving ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedScale(
                        scale: _isSaving ? 1.0 : 0.5,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                        child: const Text(
                          '💡',
                          style: TextStyle(fontSize: 48),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '灵感已捕获，正在静静发酵...',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
