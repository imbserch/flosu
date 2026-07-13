import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flosu/core/math/geometry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide PointerEvent, Image;
import 'package:flosu/models/inputs/inputs.dart';

/// Renders the health bar in the top-left corner of the gameplay HUD.
///
/// The bar follows an arbitrary [Path] shape and fills to [life] × the total
/// path length. At the current fill end-point a radial glow dot is drawn to
/// indicate health drain in real time.
///
/// [life] is a value in [0.0, 1.0] where 1.0 = full health, 0.0 = dead.
class LifeBarPainter extends CustomPainter {
  LifeBarPainter(this.life);

  /// Normalised health value. `1.0` = full, `0.0` = no health.
  final double life;

  @override
  void paint(Canvas c, Size s) {
    final borderBar = Paint()
      ..style = .stroke
      ..strokeWidth = 8
      ..strokeCap = .round
      ..strokeJoin = .round
      ..color = Colors.white;

    // Mask paint using dstIn blend mode to reveal only the filled portion
    // of the bar while erasing the unfilled portion.
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

    // The bar path — currently a horizontal line. The commented-out section
    // below shows a proposed angled shape for future iteration.
    final path = Path()
      ..moveTo(0, 8)
      ..lineTo(168, 8)
    /* 
      ..lineTo(120, 0)
      ..cubicTo(136, 0, 136, -20, 152, -20)
      ..lineTo(168, -20) */
    ;

    // Save layer so the dstIn mask only affects the white border.
    c.saveLayer(null, Paint());
    c.drawPath(path, borderBar);
    c.drawPath(path, bar);
    c.restore();

    // Compute how much of the path to fill based on [life].
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
          // Record the tip position for the glow dot.
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

    // Radial glow dot at the fill tip.
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

/// Renders the player's cursor and optional trail onto a full-screen canvas.
///
/// The cursor is drawn using a custom [cursorImage] (typically the osu! cursor
/// sprite), and the trail fades out over the last 200 ms of pointer history.
class MousePainter extends CustomPainter {
  const MousePainter({
    required this.events,
    required this.showTrail,
    required this.cursorImage,
    this.color = Colors.pink,
  }) : super(repaint: events);

  static final Paint _line = Paint()
    ..strokeCap = .butt
    ..strokeJoin = .round;

  /// Accent color for the cursor. Currently unused but kept for future use.
  final Color color;

  /// Notifier containing the recent [PointerEvent] history.
  ///
  /// The painter re-renders whenever this notifier fires.
  final ValueListenable<List<PointerEvent>> events;

  /// When true, a fading white line is drawn connecting recent cursor positions.
  final bool showTrail;

  /// Pre-loaded cursor sprite. If null, only the trail is drawn.
  final Image? cursorImage;

  @override
  void paint(Canvas c, Size s) {
    final path = events.value;

    if (path.isEmpty) return;

    final last = path.last.position;

    // Trail: iterate backwards through events, fading older segments out.
    if (path.length > 1 && showTrail) {
      final now = DateTime.now();

      for (int i = path.length - 1; i > 0; i--) {
        final difference = now.difference(path[i].timestamp);
        final progress =
            1 - (difference.inMilliseconds.clamp(0.0, 200.0) / 200);

        // Stop drawing once the trail is essentially invisible.
        if (progress <= 0.05) break;

        c.drawLine(
          path[i].position,
          path[i - 1].position,
          _line
            ..strokeWidth = 2 * progress
            ..color = Colors.white.withAlpha((255 * progress).round()),
        );
      }
    }

    // Cursor sprite rendered via atlas for performance.
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

/// Renders a replay cursor and its trail, driven by both frameTimes and frame positions
///
/// The trail is rendered using the audio position instead of the wall-clock time
/// to match the replay's original timing rather than real time.
///
/// This implementation is different from [MousePainter]
/// because the trail is not rendered in real-time
/// but using the audio position instead.
class ReplayMousePainter extends CustomPainter {
  ReplayMousePainter({
    required this.framePos,
    required this.frameTimes,
    required this.position,
    required this.showTrail,
    required this.cursorImage,
    this.color = Colors.pink,
  }) : super(repaint: position);

  static final Paint _line = Paint()
    ..strokeCap = .butt
    ..strokeJoin = .round;

  /// Accent color (currently unused).
  final Color color;

  /// Replay frame positions.
  final List<Offset> framePos;

  /// Replay frame times. Useful for finding current frame index
  final List<int> frameTimes;

  /// Current audio position in milliseconds.
  final ValueNotifier<int> position;

  /// Whether to render the fading trail.
  final bool showTrail;

  /// Pre-loaded cursor sprite. If null, only the trail is drawn.
  final Image? cursorImage;

  int _indexAt(int position) {
    final index = frameTimes.lowerBound(position, (a, b) => a.compareTo(b));
    return index;
  }

  @override
  void paint(Canvas c, Size s) {
    final maxIndex = framePos.length - 1;

    final index = _indexAt(position.value);

    final prevIndex = (index - 1).clamp(0, maxIndex);
    final currentIndex = index.clamp(0, maxIndex);

    final lastVisibleIndex = min(_indexAt(position.value - 200), maxIndex);

    // Last or interpolated frame
    Offset cursorPos = framePos[prevIndex];

    // Interpolate if between frames
    if (prevIndex < currentIndex) {
      final tStart = frameTimes[prevIndex];
      final tEnd = frameTimes[currentIndex];
      final duration = tEnd - tStart;
      if (duration > 0) {
        final t = (position.value - tStart) / duration;
        cursorPos = LineUtils.getPoint(
          framePos[prevIndex],
          framePos[currentIndex],
          t.clamp(0.0, 1.0),
        );
      }
    }

    if (showTrail) {
      // Prevent using lists (allocation minimized)
      for (int i = lastVisibleIndex; i < prevIndex; i++) {
        final current = framePos[i];
        final next = framePos[i + 1];

        final delta = position.value - frameTimes[i + 1];
        final progress = 1 - (delta.clamp(0.0, 200.0) / 200.0);

        if (progress < 0.005) continue;

        c.drawLine(
          current,
          next,
          _line
            ..color = Colors.white.withAlpha((255 * progress).round())
            ..strokeWidth = 1.5 * progress,
        );
      }
      // Connect last frame with interpolated frame
      if (prevIndex < maxIndex && cursorPos != framePos[prevIndex]) {
        final delta = position.value - frameTimes[prevIndex];
        final progress = 1 - (delta.clamp(0.0, 200.0) / 200.0);

        c.drawLine(
          framePos[prevIndex],
          cursorPos,
          _line
            ..color = Colors.white.withAlpha((255 * progress).round())
            ..strokeWidth = 1.5 * progress,
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
            translateX: cursorPos.dx,
            translateY: cursorPos.dy,
          ),
        ],
        [const Rect.fromLTWH(0, 0, 64, 64)],
        null,
        null,
        null,
        Paint()
          ..isAntiAlias = false
          ..filterQuality = FilterQuality.low,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ReplayMousePainter old) => true;
}
