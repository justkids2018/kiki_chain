import 'package:flutter/material.dart';

/// 统一的Loading组件
/// 用于所有页面的加载状态显示
class AppLoadingWidget extends StatelessWidget {
  final String? message;
  final double? progress; // 0.0 - 1.0, null表示不显示进度

  const AppLoadingWidget({
    Key? key,
    this.message,
    this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Loading indicator
              if (progress == null)
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C37D)),
                  ),
                )
              else
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00C37D)),
                    backgroundColor: Colors.grey[200],
                  ),
                ),

              if (message != null) ...[
                const SizedBox(height: 20),
                Text(
                  message!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              if (progress != null) ...[
                const SizedBox(height: 12),
                Text(
                  '${(progress! * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
