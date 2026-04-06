import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sugar_production/core/theme/app_theme.dart';

const double _kBarHeight = 68.0;
const double _kFabSize = 56.0;
const double _kFabProtrude = 28.0;

class BottomNav extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<IconData> outlineIcons;
  final List<IconData> filledIcons;
  final List<String> labels;
  final bool isDark;

  const BottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.outlineIcons,
    required this.filledIcons,
    required this.labels,
    required this.isDark,
  });

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;
  Animation<double>? _anim;
  double _fromIndex = 0;
  double _toIndex = 0;

  /// Clamps the incoming selectedIndex to a valid nav bar index (0..count-1).
  int get _safeIndex => widget.selectedIndex.clamp(0, widget.labels.length - 1);

  @override
  void initState() {
    super.initState();
    _fromIndex = _safeIndex.toDouble();
    _toIndex = _safeIndex.toDouble();

    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _anim = CurvedAnimation(parent: ctrl, curve: Curves.easeInOutCubic);
    _ctrl = ctrl;
    _ctrl!.value = 1.0;
  }

  @override
  void didUpdateWidget(BottomNav old) {
    super.didUpdateWidget(old);
    final oldSafe = old.selectedIndex.clamp(0, old.labels.length - 1);
    if (oldSafe != _safeIndex) {
      _fromIndex = oldSafe.toDouble();
      _toIndex = _safeIndex.toDouble();
      _ctrl?.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anim = _anim;
    if (anim == null) return const SizedBox.shrink();

    final count = widget.labels.length;
    final totalHeight = _kBarHeight + _kFabProtrude;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: totalHeight,
        child: AnimatedBuilder(
          animation: anim,
          builder: (context, _) {
            final animIdx = _fromIndex + (_toIndex - _fromIndex) * anim.value;

            return LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                final itemWidth = totalWidth / count;
                final centerX = (animIdx + 0.5) * itemWidth;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // ── Green bar with smooth notch ──────────────
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: _kBarHeight,
                      child: CustomPaint(
                        painter: _SmoothNotchPainter(
                          centerX: centerX,
                          color: AppTheme.primary,
                          fabSize: _kFabSize,
                          protrude: _kFabProtrude,
                        ),
                      ),
                    ),

                    // ── Nav items row ────────────────────────────
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: _kBarHeight,
                      child: Row(
                        children: List.generate(count, (i) {
                          final isSelected = _safeIndex == i;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                widget.onTap(i);
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (!isSelected) ...[
                                    Icon(
                                      widget.outlineIcons[i],
                                      size: 24,
                                      color: Colors.white.withOpacity(0.95),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.labels[i],
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withOpacity(0.95),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // ── Floating white FAB ───────────────────────
                    Positioned(
                      left: centerX - _kFabSize / 2,
                      bottom: _kBarHeight - _kFabSize / 2,
                      width: _kFabSize,
                      height: _kFabSize,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.onTap(_safeIndex);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 12,
                                spreadRadius: 1,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.filledIcons[_safeIndex],
                            size: 26,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SmoothNotchPainter extends CustomPainter {
  final double centerX;
  final Color color;
  final double fabSize;
  final double protrude;

  const _SmoothNotchPainter({
    required this.centerX,
    required this.color,
    required this.fabSize,
    required this.protrude,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final depth = fabSize / 2 + 8.0;
    const halfWidth = 90.0;
    const cp = 56.0;

    final x1 = centerX - halfWidth;
    final x2 = centerX + halfWidth;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(x1, 0);
    path.cubicTo(x1 + cp, 0, centerX - cp, depth, centerX, depth);
    path.cubicTo(centerX + cp, depth, x2 - cp, 0, x2, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.22), 10, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SmoothNotchPainter old) =>
      old.centerX != centerX || old.color != color || old.fabSize != fabSize;
}
