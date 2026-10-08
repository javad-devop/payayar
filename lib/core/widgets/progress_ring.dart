import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Single meaningful completion metric (design.md §15: progress ring
/// for one meaningful completion metric; charts stay restrained).
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.size = 128,
    this.strokeWidth = 10,
    this.center,
    this.label,
    this.color,
  });

  /// 0.0 – 1.0
  final double value;
  final double size;
  final double strokeWidth;
  final Widget? center;
  final String? label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ringColor = color ?? scheme.primary;
    final clamped = value.clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(
              value: clamped,
              strokeWidth: strokeWidth,
              ringColor: ringColor,
              trackColor: scheme.surfaceContainerHighest,
            ),
            child: Center(
              child:
                  center ??
                  Text(
                    '${(clamped * 100).round()}٪',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          fontWeight: AppFontWeight.bold,
                          color: ringColor,
                        ),
                  ),
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            label!,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.strokeWidth,
    required this.ringColor,
    required this.trackColor,
  });

  final double value;
  final double strokeWidth;
  final Color ringColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = trackColor;

    canvas.drawCircle(center, radius, track);

    if (value <= 0) return;

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = ringColor;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * value,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.ringColor != ringColor ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
