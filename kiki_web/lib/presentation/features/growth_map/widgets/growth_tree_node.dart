import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../design_ui/kiki_ui_kit.dart';
import '../../../../domain/entities/scene.dart';

enum GrowthNodeState { completed, current, available }

class GrowthTreeNode extends StatefulWidget {
  const GrowthTreeNode({
    super.key,
    required this.scene,
    required this.index,
    required this.state,
    required this.isLearned,
    required this.starsEarned,
    required this.onTap,
  });

  final Scene scene;
  final int index;
  final GrowthNodeState state;
  final bool isLearned;
  final int starsEarned;
  final VoidCallback onTap;

  @override
  State<GrowthTreeNode> createState() => _GrowthTreeNodeState();
}

class _GrowthTreeNodeState extends State<GrowthTreeNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;
  bool _isPressed = false;

  bool get _isLeft => widget.index.isEven;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulse = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.state == GrowthNodeState.current) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant GrowthTreeNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == GrowthNodeState.current &&
        oldWidget.state != GrowthNodeState.current) {
      _pulseController.repeat(reverse: true);
    } else if (widget.state != GrowthNodeState.current &&
        oldWidget.state == GrowthNodeState.current) {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final centerGap = constraints.maxWidth < 330 ? 52.0 : 70.0;
        return SizedBox(
          height: 164,
          child: CustomPaint(
            painter: _TreeBranchPainter(
              isLeft: _isLeft,
              state: widget.state,
              branchReach: centerGap / 2 + 27,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _isLeft ? _buildContent() : const SizedBox.shrink(),
                ),
                SizedBox(width: centerGap),
                Expanded(
                  child: _isLeft ? const SizedBox.shrink() : _buildContent(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Align(
      alignment: _isLeft ? Alignment.centerRight : Alignment.centerLeft,
      child: Semantics(
        button: true,
        enabled: true,
        label: widget.scene.name,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapCancel: () => setState(() => _isPressed = false),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _isPressed ? 0.96 : 1,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 170),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    _isLeft ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  _buildSceneCanopy(),
                  const SizedBox(height: 8),
                  Text(
                    widget.scene.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: _isLeft ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      color: KikiUiColors.textPrimary,
                      fontSize: 16,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStars(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSceneCanopy() {
    final isCurrent = widget.state == GrowthNodeState.current;
    final borderColor = switch (widget.state) {
      GrowthNodeState.completed => const Color(0xFF8DBD61),
      GrowthNodeState.current => const Color(0xFF6DB43F),
      GrowthNodeState.available => const Color(0xFFB8D694),
    };

    Widget canopy = Container(
      width: 86,
      height: 86,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: isCurrent ? 5 : 4),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.24),
            blurRadius: isCurrent ? 18 : 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildCoverImage(),
            if (widget.isLearned)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  key: ValueKey('learned-badge-${widget.scene.id}'),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF66AD3D),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFFFFF8E8), width: 3),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 17,
                    color: Colors.white,
                  ),
                ),
              ),
            if (widget.scene.isNew && !widget.isLearned)
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFC84A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: Color(0xFF5A3917),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (isCurrent) {
      canopy = ScaleTransition(scale: _pulse, child: canopy);
    }
    return canopy;
  }

  Widget _buildCoverImage() {
    final url = widget.scene.coverImage;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return Container(
        color: const Color(0xFFDDECC7),
        child: const Icon(Icons.eco_rounded, color: Color(0xFF6DA443)),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 180),
      placeholder: (_, __) => Container(color: const Color(0xFFDDECC7)),
      errorWidget: (_, __, ___) => Container(
        color: const Color(0xFFDDECC7),
        child: const Icon(Icons.eco_rounded, color: Color(0xFF6DA443)),
      ),
    );
  }

  Widget _buildStars() {
    return SizedBox(
      width: 140,
      child: Row(
        mainAxisAlignment:
            _isLeft ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: widget.isLearned
            ? List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Icon(
                    index < widget.starsEarned
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 17,
                    color: index < widget.starsEarned
                        ? const Color(0xFFFFB52E)
                        : const Color(0xFFC7BFAE),
                  ),
                ),
              )
            : [
                Icon(
                  key: ValueKey('unexplored-node-${widget.scene.id}'),
                  Icons.eco_outlined,
                  size: 17,
                  color: const Color(0xFF9DBA7D),
                ),
              ],
      ),
    );
  }
}

class _TreeBranchPainter extends CustomPainter {
  const _TreeBranchPainter({
    required this.isLeft,
    required this.state,
    required this.branchReach,
  });

  final bool isLeft;
  final GrowthNodeState state;
  final double branchReach;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final branchY = size.height / 2 - 12;
    final isGrown =
        state == GrowthNodeState.current || state == GrowthNodeState.completed;
    final trailColor =
        isGrown ? const Color(0xFF78A84A) : const Color(0xFFC2CBAE);

    final verticalTrail = Path()
      ..moveTo(centerX, -4)
      ..cubicTo(
        centerX + 10,
        size.height * 0.28,
        centerX - 10,
        size.height * 0.72,
        centerX,
        size.height + 4,
      );
    _drawDashedPath(canvas, verticalTrail, trailColor, 5.5, 8, 8);

    final branchEndX = isLeft ? centerX - branchReach : centerX + branchReach;
    final path = Path()
      ..moveTo(centerX, branchY + 18)
      ..quadraticBezierTo(
        centerX + (isLeft ? -18 : 18),
        branchY + 2,
        branchEndX,
        branchY,
      );
    _drawDashedPath(canvas, path, trailColor, 4.5, 7, 7);

    canvas.drawCircle(
      Offset(centerX, branchY + 16),
      5,
      Paint()..color = const Color(0xFFFFF2C7),
    );
    canvas.drawCircle(
      Offset(centerX, branchY + 16),
      2.5,
      Paint()..color = trailColor,
    );
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Color color,
    double strokeWidth,
    double dashLength,
    double gapLength,
  ) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.78)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(
              distance, (distance + dashLength).clamp(0, metric.length)),
          paint,
        );
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TreeBranchPainter oldDelegate) =>
      oldDelegate.isLeft != isLeft ||
      oldDelegate.state != state ||
      oldDelegate.branchReach != branchReach;
}
