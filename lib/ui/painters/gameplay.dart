import 'dart:ui';

import 'package:flutter/material.dart' hide PointerEvent, Image;
import 'package:flosu/models/inputs/inputs.dart';

class LifeBarPainter extends CustomPainter {
  LifeBarPainter(this.life);
  final double life;

  @override
  void paint(Canvas c, Size s) {
    final borderBar = Paint()
      ..style = .stroke
      ..strokeWidth = 8
      ..strokeCap = .round
      ..strokeJoin = .round
      ..color = Colors.white;

    final bar = Paint()
      ..style = .stroke
      ..strokeWidth = 6
      ..strokeCap = .round
      ..strokeJoin = .round
      ..color = Colors.white24
      ..blendMode = .dstIn;

    final internalBar = Paint()
      ..style = .stroke
      ..strokeWidth = 4
      ..strokeCap = .round
      ..strokeJoin = .round
      ..color = Colors.white;

    final path = Path()
      ..moveTo(0, 8)
      ..lineTo(168, 8)
    /* 
      ..lineTo(120, 0)
      ..cubicTo(136, 0, 136, -20, 152, -20)
      ..lineTo(168, -20) */
    ;

    c.saveLayer(null, Paint());
    c.drawPath(path, borderBar);
    c.drawPath(path, bar);
    c.restore();

    final metrics = path.computeMetrics().toList();
    final length = metrics.fold(0.0, (p, n) => p + n.length);

    final target = length * life;
    double current = 0;

    Offset? glowOffset;

    final internalBarPath = Path();

    for (final metric in metrics) {
      final next = current + metric.length;

      if (target > next) {
        internalBarPath.addPath(
          metric.extractPath(0, metric.length),
          Offset.zero,
        );
      } else {
        final remaining = target - current;
        if (remaining > 0) {
          glowOffset = metric.getTangentForOffset(remaining)?.position;

          internalBarPath.addPath(
            metric.extractPath(0, remaining),
            Offset.zero,
          );
        }
        break;
      }

      current = next;
    }

    if (glowOffset != null) {
      c.drawPoints(
        PointMode.points,
        [glowOffset],
        Paint()
          ..style = .stroke
          ..strokeWidth = 12
          ..strokeCap = .round
          ..strokeJoin = .round
          ..shader = RadialGradient(
            colors: [
              Colors.white,
              Colors.white.withAlpha(64),
              Colors.transparent,
            ],
            stops: [0, .25, .75],
          ).createShader(Rect.fromCircle(center: glowOffset, radius: 12)),
      );
    }

    c.drawPath(internalBarPath, internalBar);
  }

  @override
  bool shouldRepaint(covariant LifeBarPainter old) => old.life != life;
}

class MousePainter extends CustomPainter {
  const MousePainter({
    required this.events,
    required this.showTrail,
    required this.cursorImage,
    this.color = Colors.pink,
  }) : super(repaint: events);

  final Color color;
  final ValueNotifier<List<PointerEvent>> events;
  final bool showTrail;

  final Image? cursorImage;

  @override
  void paint(Canvas c, Size s) {
    final path = events.value;

    if (path.isEmpty) return;

    final last = path.last.position;

    final line = Paint()
      ..strokeCap = .butt
      ..strokeJoin = .round;

    if (path.length > 1 && showTrail) {
      final now = DateTime.now();

      for (int i = path.length - 1; i > 0; i--) {
        final difference = now.difference(path[i].timestamp);
        final progress =
            1 - (difference.inMilliseconds.clamp(0.0, 200.0) / 200);

        if (progress <= 0.05) break;

        c.drawLine(
          path[i].position,
          path[i - 1].position,
          line
            ..strokeWidth = 2 * progress
            ..color = Colors.white.withAlpha((255 * progress).round()),
        );
      }
    }

    if (cursorImage != null) {
      const scale = 1 / 3;

      c.drawAtlas(
        cursorImage!,
        [
          RSTransform.fromComponents(
            rotation: 0,
            scale: scale,
            anchorX: 32,
            anchorY: 32,
            translateX: last.dx,
            translateY: last.dy,
          ),
        ],
        [const Rect.fromLTWH(0, 0, 64, 64)],
        [Colors.white],
        .srcIn,
        null,
        Paint()
          ..isAntiAlias = false
          ..filterQuality = .low,
      );
    }
  }

  @override
  bool shouldRepaint(covariant MousePainter old) => true;
}
