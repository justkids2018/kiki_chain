// Liquid Glass 通用确认对话框组件
// 
// 基于 Liquid Glass Edition 设计规范
// 支持自定义标题、内容、按钮文案等
// 提供统一的确认对话框体验

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kikichain/generated/app_localizations.dart';

class LiquidConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String? confirmText;
  final String? cancelText;
  final bool isDestructive;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const LiquidConfirmDialog({
    Key? key,
    required this.title,
    required this.content,
    this.confirmText,
    this.cancelText,
    this.isDestructive = false,
    this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.7 + (0.3 * value),
          child: Opacity(
            opacity: value,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                width: 400,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 30,
                            offset: Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.2),
                            blurRadius: 1,
                            offset: Offset(0, 1),
                            blurStyle: BlurStyle.inner,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 标题
                            Text(
                              title,
                              style: TextStyle(
                                color: Color(0xFF27273F),
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.01,
                              ),
                            ),
                            SizedBox(height: 16),
                            // 内容描述
                            Text(
                              content,
                              style: TextStyle(
                                color: Color(0xFF27273F).withValues(alpha: 0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 28),
                            // 操作按钮
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _buildLiquidDialogButton(
                                  text: cancelText ?? localizations.cancel,
                                  onTap: () {
                                    Navigator.of(context).pop(false);
                                    onCancel?.call();
                                  },
                                  isSecondary: true,
                                ),
                                SizedBox(width: 12),
                                _buildLiquidDialogButton(
                                  text: confirmText ?? localizations.confirm,
                                  onTap: () {
                                    Navigator.of(context).pop(true);
                                    onConfirm?.call();
                                  },
                                  isDestructive: isDestructive,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Liquid Glass 对话框按钮
  Widget _buildLiquidDialogButton({
    required String text,
    required VoidCallback onTap,
    bool isSecondary = false,
    bool isDestructive = false,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSecondary 
                  ? Colors.white.withValues(alpha: 0.1)
                  : isDestructive
                      ? Colors.red.withValues(alpha: 0.1)
                      : Color(0xFF00C37D).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSecondary
                    ? Colors.white.withValues(alpha: 0.2)
                    : isDestructive
                        ? Colors.red.withValues(alpha: 0.3)
                        : Color(0xFF00C37D).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isSecondary
                    ? Color(0xFF27273F)
                    : isDestructive
                        ? Colors.red
                        : Color(0xFF00C37D),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.01,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 显示确认对话框的静态方法
  /// 
  /// 使用示例：
  /// ```dart
  /// final confirmed = await LiquidConfirmDialog.show(
  ///   context: context,
  ///   title: '确认删除',
  ///   content: '确定要删除这个作业吗？此操作不可撤销。',
  ///   confirmText: '删除',
  ///   cancelText: '取消',
  ///   isDestructive: true,
  /// );
  /// if (confirmed == true) {
  ///   // 执行确认操作
  /// }
  /// ```
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    bool isDestructive = false,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (BuildContext context) {
        return LiquidConfirmDialog(
          title: title,
          content: content,
          confirmText: confirmText,
          cancelText: cancelText,
          isDestructive: isDestructive,
          onConfirm: onConfirm,
          onCancel: onCancel,
        );
      },
    );
  }
}
