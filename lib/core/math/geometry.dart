import 'package:flutter/services.dart';

/// Utility class for computing straight-line segments.
///
/// Used to render sliders whose curve type is [SliderCurve.lineal], and as a
/// fallback for degenerate Bézier and arc segments.
class LineUtils {
  /// Linear interpolation between [a] and [b] at parameter [t] ∈ [0, 1].
  static Offset getPoint(Offset a, Offset b, double t) {
    return Offset(a.dx + t * (b.dx - a.dx), a.dy + t * (b.dy - a.dy));
  }
}

/// Miscellaneous helper functions for processing slider curve point lists.
class CurveUtils {
  /// Removes any [Offset] whose components are NaN.
  ///
  /// NaN values can appear in degenerate arc computations and must be removed
  /// before the points are passed to the canvas.
  static List<Offset> removeNaN(List<Offset> points) {
    return points.where((o) => !o.dx.isNaN && !o.dy.isNaN).toList();
  }

  /// Splits a flat list of control points into segments at duplicate points.
  ///
  /// In the osu! file format, a duplicated control point acts as a "hard
  /// anchor" that terminates the current Bézier sub-segment and starts a new
  /// one. This function performs that split.
  ///
  /// Example: `[A, B, B, C, D]` → `[[A, B], [B, C, D]]`
  static List<List<Offset>> toSegments(List<Offset> points) {
    final List<List<Offset>> segments = [];
    List<Offset> currentSegment = [];

    for (int i = 0; i < points.length; i++) {
      currentSegment.add(points[i]);

      if (i + 1 < points.length && points[i] == points[i + 1]) {
        segments.add(currentSegment);
        currentSegment = [];
      }
    }

    if (currentSegment.isNotEmpty) segments.add(currentSegment);
    return segments;
  }
}
