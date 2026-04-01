import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/scene.dart';
import '../../generated/app_localizations.dart';

/// 场景卡片组件
///
/// 尺寸: 350x450px (7:9 宽高比)
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
      child: AspectRatio(
        aspectRatio: 7 / 9, // 保持 7:9 宽高比
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
      ),
    );
  }

  /// 构建封面图片
  Widget _buildCoverImage() {
    if (scene.coverImage.isEmpty ||
        (!scene.coverImage.startsWith('http://') &&
         !scene.coverImage.startsWith('https://'))) {
      return Container(
        color: _getSceneColor(),
        child: const Center(
          child: Icon(Icons.image_outlined, size: 48, color: Colors.white),
        ),
      );
    }
    return Positioned.fill(
      child: CachedNetworkImage(
        imageUrl: scene.coverImage,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: _getSceneColor().withValues(alpha: 0.3),
          child: const Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
        errorWidget: (context, url, error) => Container(
          color: _getSceneColor(),
          child: const Center(
            child: Icon(Icons.image_outlined, size: 48, color: Colors.white),
          ),
        ),
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
      left: 12,
      right: 12,
      bottom: 12,
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 场景名称
              Text(
                scene.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),

              // 英文名称
              Text(
                scene.nameEn,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
  }

  /// 构建 NEW 标签
  Widget _buildNewBadge() {
    return Positioned(
      top: 10,
      right: 10,
      child: Builder(
        builder: (context) {
          final localizations = AppLocalizations.of(context)!;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF00C37D),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              localizations.newBadge,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
        },
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
