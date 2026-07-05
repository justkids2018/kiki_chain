import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../design_ui/kiki_ui_kit.dart';
import '../../../../domain/entities/scene.dart';
import '../../../../domain/entities/scene_category.dart';
import '../../../../generated/app_localizations.dart';
import '../../../controllers/scene_list_controller.dart';
import '../../../widgets/app_loading_widget.dart';
import '../../../widgets/glass_back_button.dart';
import '../widgets/growth_tree_node.dart';

/// A new visual treatment for the existing scene list flow.
///
/// It intentionally reuses [SceneListController], so scene loading and
/// navigation to learning cards remain unchanged.
class GrowthMapPage extends StatefulWidget {
  const GrowthMapPage({
    super.key,
    required this.category,
    this.controller,
  });

  final SceneCategory category;
  final SceneListController? controller;

  @override
  State<GrowthMapPage> createState() => _GrowthMapPageState();
}

class _GrowthMapPageState extends State<GrowthMapPage> {
  static const double _nodeHeight = 164;
  static const double _selectedNodeViewportRatio = 0.38;
  final ScrollController _scrollController = ScrollController();
  bool _hasPositionedInitialScene = false;
  bool _isPositioningInitialScene = false;
  int? _positionedSceneIndex;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SceneListController>(
      tag: widget.category.id,
      init: widget.controller ?? SceneListController(category: widget.category),
      global: false,
      autoRemove: true,
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5E9D2),
          body: Stack(
            fit: StackFit.expand,
            children: [
              const RepaintBoundary(child: _ForestBackdrop()),
              const _MapIllustrationLayer(),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 760) {
                      return _buildMapPane(controller);
                    }
                    return Row(
                      children: [
                        Expanded(child: _buildMapPane(controller)),
                        Expanded(child: _buildScenePreview(controller)),
                      ],
                    );
                  },
                ),
              ),
              const _MapCharacterOverlay(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapPane(SceneListController controller) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: _buildBody(controller)),
        Align(
          alignment: Alignment.topCenter,
          child: _GrowthMapHeader(category: widget.category),
        ),
      ],
    );
  }

  Widget _buildScenePreview(SceneListController controller) {
    return Obx(() {
      if (controller.scenes.isEmpty) return const SizedBox.shrink();
      final index = controller.restoredSceneIndex.value
          .clamp(0, controller.scenes.length - 1);
      final scene = controller.scenes[index];
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 124),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final byWidth = constraints.maxWidth * 0.9;
            final byHeight = constraints.maxHeight * 0.9;
            final cardSize = byWidth < byHeight ? byWidth : byHeight;
            return Center(
              child: SizedBox.square(
                dimension: cardSize,
                child: Semantics(
                  button: true,
                  label: '开始学习 ${scene.name}',
                  child: GestureDetector(
                    key: const ValueKey('selected-scene-preview'),
                    onTap: () async {
                      await controller.navigateToSceneDetail(
                        scene,
                        selectedIndex: index,
                      );
                      _scrollToIndex(controller.restoredSceneIndex.value);
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: _ScenePreviewCard(
                        key: ValueKey(scene.id),
                        scene: scene,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildBody(SceneListController controller) {
    final l10n = AppLocalizations.of(context)!;
    return Obx(() {
      if (controller.isLoadingScenes.value) {
        return AppLoadingWidget(message: l10n.loading);
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return _MapMessage(
          icon: Icons.cloud_off_rounded,
          title: l10n.loadFailed,
          actionLabel: l10n.retry,
          onAction: controller.refreshScenes,
        );
      }

      if (controller.scenes.isEmpty) {
        return _MapMessage(
          icon: Icons.park_outlined,
          title: l10n.noScenes,
        );
      }

      final selectedIndex = controller.restoredSceneIndex.value;
      _positionSelectedScene(controller, selectedIndex);
      return LayoutBuilder(
        builder: (context, constraints) {
          final selectedNodeY =
              constraints.maxHeight * _selectedNodeViewportRatio;
          final topInset = (selectedNodeY - _nodeHeight / 2).clamp(0.0, 400.0);
          final bottomInset =
              (constraints.maxHeight - selectedNodeY - _nodeHeight / 2)
                  .clamp(0.0, 400.0);
          return ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(18, topInset, 18, bottomInset),
            itemExtent: _nodeHeight,
            itemCount: controller.scenes.length,
            itemBuilder: (context, index) {
              final scene = controller.scenes[index];
              final isCurrent = index == controller.restoredSceneIndex.value;
              final isLearned = controller.isSceneLearned(scene.id);
              final state = isCurrent
                  ? GrowthNodeState.current
                  : isLearned
                      ? GrowthNodeState.completed
                      : GrowthNodeState.available;

              return GrowthTreeNode(
                key: ValueKey(scene.id),
                scene: scene,
                index: index,
                state: state,
                isLearned: isLearned,
                starsEarned: controller.starsForScene(scene.id),
                onTap: () => _selectScene(controller, scene, index),
              );
            },
          );
        },
      );
    });
  }

  void _positionInitialScene(SceneListController controller) {
    if (_hasPositionedInitialScene || _isPositioningInitialScene) return;
    _isPositioningInitialScene = true;
    _attemptInitialPosition(controller, remainingAttempts: 4);
  }

  void _attemptInitialPosition(
    SceneListController controller, {
    required int remainingAttempts,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_scrollController.hasClients) {
        if (remainingAttempts > 0) {
          _attemptInitialPosition(
            controller,
            remainingAttempts: remainingAttempts - 1,
          );
        } else {
          _isPositioningInitialScene = false;
        }
        return;
      }
      final target = controller.restoredSceneIndex.value * _nodeHeight;
      _scrollController.jumpTo(
        target.clamp(0, _scrollController.position.maxScrollExtent),
      );
      _hasPositionedInitialScene = true;
      _positionedSceneIndex = controller.restoredSceneIndex.value;
      _isPositioningInitialScene = false;
    });
  }

  void _positionSelectedScene(
    SceneListController controller,
    int selectedIndex,
  ) {
    if (!_hasPositionedInitialScene) {
      _positionInitialScene(controller);
      return;
    }
    if (_positionedSceneIndex == selectedIndex) return;
    _positionedSceneIndex = selectedIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToIndex(selectedIndex);
    });
  }

  Future<void> _selectScene(
    SceneListController controller,
    Scene scene,
    int index,
  ) async {
    if (index == controller.restoredSceneIndex.value) {
      await controller.navigateToSceneDetail(scene, selectedIndex: index);
      _scrollToIndex(controller.restoredSceneIndex.value);
      return;
    }
    controller.persistSelectedSceneIndex(index);
    if (!_scrollController.hasClients) return;
    final target = index * _nodeHeight;
    _scrollController.animateTo(
      target.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollToIndex(int index) {
    if (!_scrollController.hasClients) return;
    final target = index * _nodeHeight;
    _scrollController.animateTo(
      target.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }
}

class _ScenePreviewCard extends StatelessWidget {
  const _ScenePreviewCard({super.key, required this.scene});

  final Scene scene;

  @override
  Widget build(BuildContext context) {
    final imageUrl = scene.interactiveImage.isNotEmpty
        ? scene.interactiveImage
        : scene.coverImage;
    final hasNetworkImage =
        imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE7D5AC), width: 2),
        boxShadow: KikiUiShadows.floating,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: hasNetworkImage
            ? Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const _PreviewFallback(),
              )
            : const _PreviewFallback(),
      ),
    );
  }
}

class _PreviewFallback extends StatelessWidget {
  const _PreviewFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFE5EFCF),
      child: Center(
        child: Icon(Icons.image_outlined, color: Color(0xFF78A44F), size: 64),
      ),
    );
  }
}

class _GrowthMapHeader extends StatelessWidget {
  const _GrowthMapHeader({required this.category});

  final SceneCategory category;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: SizedBox(
        height: 54,
        child: Row(
          children: [
            const GlassBackButton(),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: KikiUiColors.textPrimary,
                  fontSize: 22,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapIllustrationLayer extends StatelessWidget {
  const _MapIllustrationLayer();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: -30,
            right: -30,
            bottom: -18,
            child: Image.asset(
              'assets/images/growth_map/meadow_wide.png',
              height: 132,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapCharacterOverlay extends StatelessWidget {
  const _MapCharacterOverlay();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child:
          Align(alignment: Alignment.bottomCenter, child: _MapCharacterGroup()),
    );
  }
}

class _MapCharacterGroup extends StatelessWidget {
  const _MapCharacterGroup();

  static const double _groupScale = 0.9;
  static const double _peopleScale = 0.8 * _groupScale;
  static const double _mimiScale = 0.8 * _groupScale;
  static const double _easelScale = 1.36 * _groupScale;
  static const double _groupWidth =
      180 * _peopleScale + 165 * _peopleScale + 66 + 136 * _mimiScale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: Alignment.bottomRight,
          child: SizedBox(
            width: constraints.maxWidth / 2,
            height: 264,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.bottomLeft,
              child: SizedBox(
                width: _groupWidth,
                height: 264,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Transform.translate(
                    offset: const Offset(0, 50),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const _MapCharacter(
                          assetPath: 'assets/images/growth_map/yuki_map.png',
                          width: 180 * _peopleScale,
                          angle: -0.02,
                          label: 'Yuki 和 Kiki 坐在草地上一起学习',
                        ),
                        const _MapCharacter(
                          assetPath: 'assets/images/growth_map/kiki_map.png',
                          width: 165 * _peopleScale,
                          angle: 0.03,
                          label: 'Kiki 坐在 Yuki 身边',
                        ),
                        Transform.translate(
                          offset: const Offset(0, -73),
                          child: SizedBox(
                            width: 66,
                            height: 90,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Transform.scale(
                                scale: _easelScale,
                                alignment: Alignment.bottomCenter,
                                child: const _MiniEasel(),
                              ),
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -50),
                          child: const _MapCharacter(
                            assetPath: 'assets/images/growth_map/mimi_map.png',
                            width: 136 * _mimiScale,
                            angle: 0.02,
                            label: 'Mimi 在草地上看画',
                          ),
                        ),
                      ],
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
}

class _MiniEasel extends StatelessWidget {
  const _MiniEasel();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MiniEaselPainter(),
      child: const SizedBox(width: 48, height: 66),
    );
  }
}

class _MiniEaselPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final wood = Paint()
      ..color = const Color(0xFF9A6938)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(18, 38), const Offset(10, 64), wood);
    canvas.drawLine(const Offset(30, 38), const Offset(39, 64), wood);
    canvas.drawLine(const Offset(24, 38), const Offset(24, 64), wood);

    final frame = RRect.fromRectAndRadius(
      const Rect.fromLTWH(3, 2, 42, 39),
      const Radius.circular(4),
    );
    canvas.drawRRect(frame, Paint()..color = const Color(0xFFFFF3D1));
    canvas.drawRRect(
      frame,
      Paint()
        ..color = const Color(0xFFC28B4C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(
      const Offset(34, 12),
      5,
      Paint()..color = const Color(0xFFFFCE58),
    );
    canvas.drawLine(
      const Offset(8, 34),
      const Offset(21, 22),
      Paint()
        ..color = const Color(0xFF8FC35C)
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      const Offset(38, 34),
      const Offset(26, 20),
      Paint()
        ..color = const Color(0xFF6FAE54)
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapCharacter extends StatelessWidget {
  const _MapCharacter({
    required this.assetPath,
    required this.width,
    required this.angle,
    required this.label,
  });

  final String assetPath;
  final double width;
  final double angle;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Semantics(
        label: label,
        image: true,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              bottom: 0,
              child: Container(
                width: width * 0.68,
                height: width * 0.14,
                decoration: BoxDecoration(
                  color: const Color(0xFF55743A).withValues(alpha: 0.30),
                  borderRadius: BorderRadius.circular(width),
                ),
              ),
            ),
            Image.asset(
              assetPath,
              width: width,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ],
        ),
      ),
    );
  }
}

class _MapMessage extends StatelessWidget {
  const _MapMessage({
    required this.icon,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 58, color: const Color(0xFF91A678)),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: KikiUiColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: KikiUiColors.brandGreen,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _ForestBackdrop extends StatelessWidget {
  const _ForestBackdrop();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ForestBackdropPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _ForestBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF8F0DA), Color(0xFFE8EBCB), Color(0xFFD6E3B5)],
        stops: [0, 0.52, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    final sun = Paint()
      ..color = const Color(0xFFFFD984).withValues(alpha: 0.34);
    canvas.drawCircle(Offset(size.width * 0.83, size.height * 0.14), 76, sun);

    final distantLeaves = Paint()
      ..color = const Color(0xFFAFC887).withValues(alpha: 0.30);
    final nearLeaves = Paint()
      ..color = const Color(0xFF7EAA59).withValues(alpha: 0.18);
    for (var i = 0; i < 7; i++) {
      final y = size.height * (0.18 + i * 0.13);
      canvas.drawCircle(Offset(-18, y), 54 + (i % 2) * 16, distantLeaves);
      canvas.drawCircle(
        Offset(size.width + 12, y + 28),
        46 + ((i + 1) % 3) * 12,
        i.isEven ? distantLeaves : nearLeaves,
      );
    }

    final ground = Path()
      ..moveTo(0, size.height * 0.88)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.83,
        size.width * 0.62,
        size.height * 0.91,
      )
      ..quadraticBezierTo(
        size.width * 0.84,
        size.height * 0.96,
        size.width,
        size.height * 0.89,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      ground,
      Paint()..color = const Color(0xFF9DB96E).withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
