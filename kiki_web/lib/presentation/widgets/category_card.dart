import 'dart:ui';
import 'package:flutter/material.dart';
import '../../domain/entities/scene_category.dart';
import '../../generated/app_localizations.dart';

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
        // 全屏高度，宽由父组件控制
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            // 主阴影 - 更强的立体感
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            // 次阴影 - 柔和的扩散
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 40,
              offset: const Offset(0, 12),
              spreadRadius: -4,
            ),
            // 顶部高光 - 增强凸起效果
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.5),
              blurRadius: 1,
              offset: const Offset(0, -1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16), // 圆角裁剪（从24改成16）
          child: Stack(
            fit: StackFit.expand,
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
    // 如果封面图片为空或无效，直接显示占位符
    if (category.coverImage.isEmpty ||
        (!category.coverImage.startsWith('http://') &&
         !category.coverImage.startsWith('https://'))) {
      return Container(
        color: _getCategoryColor(),
        child: Center(
          child: Text(
            category.icon,
            style: const TextStyle(fontSize: 120),
          ),
        ),
      );
    }

    return Positioned.fill(
      child: Image.network(
        category.coverImage,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: _getCategoryColor().withValues(alpha: 0.3),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: Colors.white,
              ),
            ),
          );
        },
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
    return Builder(
      builder: (context) {
        final localizations = AppLocalizations.of(context)!;
        return Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 分类名称（标题变小）
              Text(
                category.name,
                style: const TextStyle(
                  fontSize: 24, // 从28改成24
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6), // 从8改成6

              // 描述（内容变小）
              Text(
                category.description,
                style: TextStyle(
                  fontSize: 12, // 从14改成12
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.3, // 从1.4改成1.3
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10), // 从12改成10

              // 场景数量
              _buildInfoChip(
                icon: Icons.grid_view_rounded,
                text: localizations.scenesCount(category.sceneCount),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建信息标签（毛玻璃效果）
  Widget _buildInfoChip({required IconData icon, required String text}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.3), // 灰色毛玻璃
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 12, // 符合最小尺寸要求
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 12, // 符合项目规范最小字号 12px
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建 NEW 标签
  Widget _buildNewBadge() {
    return Positioned(
      top: 16,
      right: 16,
      child: Builder(
        builder: (context) {
          final localizations = AppLocalizations.of(context)!;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00C37D),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              localizations.newBadge,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
        },
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
