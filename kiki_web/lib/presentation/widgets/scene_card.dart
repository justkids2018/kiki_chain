import 'package:flutter/material.dart';
import '../../domain/entities/scene.dart';

/// 场景卡片组件
///
/// 用于场景列表页展示单个场景
class SceneCard extends StatelessWidget {
  final Scene scene;
  final VoidCallback? onTap;

  const SceneCard({
    Key? key,
    required this.scene,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // 背景图片
              _buildCoverImage(),

              // 渐变遮罩
              _buildGradientOverlay(),

              // 内容区域
              _buildContent(),

              // NEW 标签
              if (scene.isNew) _buildNewBadge(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建封面图片
  Widget _buildCoverImage() {
    return Positioned.fill(
      child: Image.asset(
        scene.coverImage,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // 如果图片加载失败，显示占位符
          return Container(
            color: _getSceneColor(),
            child: const Center(
              child: Icon(
                Icons.image_outlined,
                size: 48,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建渐变遮罩
  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.6),
            ],
            stops: const [0.6, 1.0],
          ),
        ),
      ),
    );
  }

  /// 构建内容区域
  Widget _buildContent() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 场景名称
          Text(
            scene.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // 英文名称
          Text(
            scene.nameEn,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // 物品数量
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.category_rounded,
                  size: 12,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  '${scene.itemCount}个物品',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建 NEW 标签
  Widget _buildNewBadge() {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'NEW',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// 根据场景ID获取主题色
  Color _getSceneColor() {
    // 根据场景ID的哈希值生成颜色
    final hash = scene.id.hashCode;
    final colors = [
      Colors.blue.shade300,
      Colors.purple.shade300,
      Colors.orange.shade300,
      Colors.green.shade300,
      Colors.pink.shade300,
      Colors.teal.shade300,
    ];
    return colors[hash.abs() % colors.length];
  }
}
