import 'package:flutter/material.dart';
import '../../domain/entities/scene_category.dart';

/// 场景分类卡片组件
///
/// 尺寸: 350x450px
/// 用于首页展示场景分类
class CategoryCard extends StatelessWidget {
  final SceneCategory category;
  final VoidCallback? onTap;

  const CategoryCard({
    Key? key,
    required this.category,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 350,
        height: 450,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // 背景图片
              _buildCoverImage(),

              // 渐变遮罩
              _buildGradientOverlay(),

              // 内容区域
              _buildContent(),

              // NEW 标签
              if (category.isNew) _buildNewBadge(),
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
        category.coverImage,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // 如果图片加载失败，显示占位符
          return Container(
            color: _getCategoryColor(),
            child: Center(
              child: Text(
                category.icon,
                style: const TextStyle(fontSize: 120),
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
              Colors.black.withValues(alpha: 0.7),
            ],
            stops: const [0.5, 1.0],
          ),
        ),
      ),
    );
  }

  /// 构建内容区域
  Widget _buildContent() {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 图标
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                category.icon,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 分类名称
          Text(
            category.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          // 描述
          Text(
            category.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // 场景数量和物品数量
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.grid_view_rounded,
                text: '${category.sceneCount}个场景',
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                icon: Icons.category_rounded,
                text: '${category.totalItemCount}个物品',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建信息标签
  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建 NEW 标签
  Widget _buildNewBadge() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'NEW',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// 根据分类获取主题色
  Color _getCategoryColor() {
    switch (category.id) {
      case 'category_daily_life':
        return Colors.blue.shade300;
      case 'category_playground':
        return Colors.purple.shade300;
      case 'category_numbers':
        return Colors.orange.shade300;
      case 'category_letters':
        return Colors.green.shade300;
      case 'category_traditional_festivals':
        return Colors.red.shade300;
      default:
        return Colors.grey.shade300;
    }
  }
}
