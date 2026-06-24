import 'dart:math';
import 'dart:ui';
import 'dart:typed_data';

/// Minimum distance between consecutive sampled points when building a curve.
///
/// Points closer than this threshold are filtered out to reduce overdraw.
const double _curveSubdivisions = 2.0;
const double _distanceThreshold = 4.0;

// =============================================================================
// Bezier
// =============================================================================

/// Utility class for computing Bézier curves using De Casteljau's algorithm.
///
/// Used to render sliders whose curve type is [SliderCurve.bezier].
class Bezier {
  /// Approximates the arc length of a Bézier curve defined by [points].
  ///
  /// For curves with more than 20 control points a [Polyline] approximation
  /// is used for performance. Shorter curves are sampled at intervals
  /// proportional to the number of control points.
  static double getLength(List<Offset> points) {
    if (points.length > 20) {
      return Polyline.getLength(points);
    } else {
      final steps = points.length * _curveSubdivisions;

      double totalLen = 0;
      Offset lastPoint = points[0];

      for (int i = 1; i <= steps; i++) {
        final t = i / steps;
        Offset currentPoint = getPoint(points, t);
        totalLen += (currentPoint - lastPoint).distance;
        lastPoint = currentPoint;
      }

      return totalLen;
    }
  }

  /// Returns the point on the Bézier curve at parameter [t] ∈ [0, 1].
  ///
  /// Uses the iterative De Casteljau algorithm, which is numerically stable
  /// for arbitrary-degree curves.
  static Offset getPoint(List<Offset> points, double t) {
    List<Offset> temp = List.from(points);
    int n = temp.length;

    for (int j = 1; j < n; j++) {
      for (int i = 0; i < n - j; i++) {
        temp[i] = Offset(
          (1 - t) * temp[i].dx + t * temp[i + 1].dx,
          (1 - t) * temp[i].dy + t * temp[i + 1].dy,
        );
      }
    }

    return temp[0];
  }

  /// Samples the Bézier curve into a list of [Offset] points.
  ///
  /// The number of samples is proportional to the curve's length divided by
  /// [_curveSubdivisions]. Points that fall within [_distanceThreshold] of
  /// the previous point are discarded to avoid redundant geometry.
  static List<Offset> getSpline(List<Offset> points) {
    final length = getLength(points);

    final multSegments = (length / _curveSubdivisions).ceil();

    List<Offset> curve = [];

    for (int i = 0; i <= multSegments; i++) {
      final t = i / multSegments;
      curve.add(getPoint(points, t));
    }

    final List<Offset> filtered = [curve.first];

    for (int i = 1; i < curve.length; i++) {
      final current = curve[i];

      if ((current - filtered.last).distance >= _distanceThreshold) {
        filtered.add(current);
      }
    }

    return filtered;
  }
}

// =============================================================================
// Arc
// =============================================================================

/// Utility class for computing circular arc curves defined by three points.
///
/// Used to render sliders whose curve type is [SliderCurve.perfect].
class Arc {
  /// Internal helper that computes the geometric properties of an arc passing
  /// through [points[0]], [points[1]], and [points[2]].
  ///
  /// Returns `null` if the three points are collinear (no unique circle exists).
  static ({Offset center, List<double> radius, List<double> angles})? _getData(
    List<Offset> points,
  ) {
    final pX = points.map((p) => p.dx).toList();
    final pY = points.map((p) => p.dy).toList();

    // The determinant is zero when all three points are collinear.
    final d =
        2 *
        (pX[0] * (pY[1] - pY[2]) +
            pX[1] * (pY[2] - pY[0]) +
            pX[2] * (pY[0] - pY[1]));

    if (d.abs() < 0.0001) return null;

    // Circumcenter of the three points.
    double cX =
        ((pow(pX[0], 2) + pow(pY[0], 2)) * (pY[1] - pY[2]) +
            (pow(pX[1], 2) + pow(pY[1], 2)) * (pY[2] - pY[0]) +
            (pow(pX[2], 2) + pow(pY[2], 2)) * (pY[0] - pY[1])) /
        d;

    double cY =
        ((pow(pX[0], 2) + pow(pY[0], 2)) * (pX[2] - pX[1]) +
            (pow(pX[1], 2) + pow(pY[1], 2)) * (pX[0] - pX[2]) +
            (pow(pX[2], 2) + pow(pY[2], 2)) * (pX[1] - pX[0])) /
        d;

    final center = Offset(cX, cY);

    // Radii from the circumcenter to each control point.
    final radius = [
      (points[0] - center).distance,
      (points[1] - center).distance,
      (points[2] - center).distance,
    ];

    // Angles (in radians) from the circumcenter to each control point.
    final angles = [
      atan2(pY[0] - cY, pX[0] - cX),
      atan2(pY[1] - cY, pX[1] - cX),
      atan2(pY[2] - cY, pX[2] - cX),
    ];

    // Normalize to ensure smooth angle interpolation without wrapping.
    double diff12 = angles[1] - angles[0];
    if (diff12 <= -pi) diff12 += 2 * pi;
    if (diff12 > pi) diff12 -= 2 * pi;
    angles[1] = angles[0] + diff12;

    double diff23 = angles[2] - angles[1];
    if (diff23 <= -pi) diff23 += 2 * pi;
    if (diff23 > pi) diff23 -= 2 * pi;
    angles[2] = angles[1] + diff23;

    return (center: center, radius: radius, angles: angles);
  }

  /// Returns the arc position at parameter [t] ∈ [0, 1].
  ///
  /// The arc is split into two halves at t = 0.5 (point 0→1, then 1→2).
  /// Both the radius and the angle are interpolated linearly within each half
  /// to support slightly non-circular arcs.
  static Offset getPoint(
    Offset center,
    List<double> radius,
    List<double> angles,
    double t,
  ) {
    double startRadius, endRadius, startAngle, endAngle, localT;

    if (t < .5) {
      startRadius = radius[0];
      endRadius = radius[1];
      startAngle = angles[0];
      endAngle = angles[1];
      localT = t * 2;
    } else {
      startRadius = radius[1];
      endRadius = radius[2];
      startAngle = angles[1];
      endAngle = angles[2];
      localT = (t - .5) * 2;
    }

    double currentRadius = startRadius + (endRadius - startRadius) * localT;
    double currentAngle = startAngle + (endAngle - startAngle) * localT;

    return Offset(
      center.dx + currentRadius * cos(currentAngle),
      center.dy + currentRadius * sin(currentAngle),
    );
  }

  /// Approximates the total arc length for the three-point arc.
  ///
  /// Returns `null` if the points are collinear.
  static double? getLength(List<Offset> points) {
    final data = _getData(points);

    if (data == null) return null;

    // Arc length = average_radius × angular_sweep for each half.
    final sweepStart = (data.angles[1] - data.angles[0]).abs();
    final radiusStart = (data.radius[0] + data.radius[1]) / 2;
    final startMidLength = radiusStart * sweepStart;

    final sweepEnd = (data.angles[2] - data.angles[1]).abs();
    final radiusEnd = (data.radius[1] + data.radius[2]) / 2;
    final midEndLength = radiusEnd * sweepEnd;

    return startMidLength + midEndLength;
  }

  /// Samples the arc path into an [Offset] list.
  ///
  /// Falls back to returning [points] unchanged if the geometry is undefined.
  static List<Offset> getSpline(List<Offset> points) {
    List<Offset> arc = [];

    final data = _getData(points);
    if (data == null) return points;

    final multSegments = getLength(points)! / _curveSubdivisions;

    for (int i = 0; i <= multSegments; i++) {
      final t = i / multSegments;
      arc.add(getPoint(data.center, data.radius, data.angles, t));
    }

    final List<Offset> filtered = [arc.first];

    for (int i = 1; i < arc.length; i++) {
      final current = arc[i];

      if ((current - filtered.last).distance >= _distanceThreshold) {
        filtered.add(current);
      }
    }

    return filtered;
  }
}

// =============================================================================
// Line
// =============================================================================

/// Utility class for computing straight-line segments.
///
/// Used to render sliders whose curve type is [SliderCurve.lineal], and as a
/// fallback for degenerate Bézier and arc segments.
class Line {
  /// Returns the Euclidean distance between the first and last point.
  static double getLength(List<Offset> points) {
    return (points.first - points.last).distance;
  }

  /// Linear interpolation between [a] and [b] at parameter [t] ∈ [0, 1].
  static Offset getPoint(Offset a, Offset b, double t) {
    return Offset(a.dx + t * (b.dx - a.dx), a.dy + t * (b.dy - a.dy));
  }

  /// Samples the line into evenly spaced [Offset] points.
  static List<Offset> getSpline(List<Offset> points) {
    final length = getLength(points);

    final segments = (length / _curveSubdivisions).ceil();

    final List<Offset> line = [];

    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      line.add(getPoint(points.first, points.last, t));
    }

    final List<Offset> filtered = [line.first];

    for (int i = 1; i < line.length; i++) {
      final current = line[i];

      if ((current - filtered.last).distance >= _distanceThreshold) {
        filtered.add(current);
      }
    }

    return filtered;
  }
}

// =============================================================================
// Polyline
// =============================================================================

/// Utility class for approximating a curve as a series of connected line
/// segments between control points.
///
/// Used as a performance fallback for Bézier curves with many control points.
class Polyline {
  /// Returns the total length of the polyline formed by connecting [points]
  /// in order.
  static double getLength(List<Offset> points) {
    double polyLen = 0;

    for (int i = 1; i < points.length; i++) {
      polyLen += Line.getLength([points[i - 1], points[i]]);
    }

    return polyLen;
  }

  /// Samples the polyline into an [Offset] list by applying [Line.getSpline]
  /// to each consecutive pair of control points.
  static List<Offset> getSpline(List<Offset> points) {
    final List<Offset> polyline = [];

    for (int i = 1; i < points.length; i++) {
      final segment = [points[i - 1], points[i]];
      final linePoints = Line.getSpline(segment);

      // Avoid duplicating junction points between segments.
      if (polyline.isNotEmpty) linePoints.removeAt(0);
      polyline.addAll(linePoints);
    }

    return polyline;
  }
}

// =============================================================================
// CurveUtils
// =============================================================================

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

// =============================================================================
// VerticesUtils
// =============================================================================

/// Utility class that converts a polyline into a [Vertices] object suitable
/// for rendering with [Canvas.drawVertices].
///
/// This produces a thick "tube" geometry with rounded end caps, used to draw
/// the slider body as a filled shape rather than a stroked path.
///
/// > ⚠️ **Note**: This implementation was machine-generated and has not been
/// > fully optimised. In particular, the cap geometry generates O(n) extra
/// > triangles per segment and the vertex buffer is not reused between frames.
/// > Consider replacing with a pre-computed vertex cache or a [Path]-based
/// > approach if performance becomes a concern.
class VerticesUtils {
  /// Generates a [Vertices] object representing a rounded thick line along
  /// [points] with a total stroke width of [strokeWidth].
  ///
  /// The output geometry consists of:
  /// - A rectangular quad for each line segment.
  /// - A rounded half-disk cap at the start of each segment.
  /// - A rounded half-disk cap at the end of each segment.
  static Vertices generateVertices(
    List<Offset> points, {
    required double strokeWidth,
  }) {
    if (points.length < 2) {
      // Return a safe empty object when there are not enough points.
      return Vertices.raw(VertexMode.triangles, Float32List(0));
    }

    final double radius = strokeWidth / 2;
    const int capSegments = 16;

    final List<double> rawVertices = [];
    final List<int> indices = [];

    for (int i = 0; i < points.length - 1; i++) {
      Offset p0 = points[i];
      Offset p1 = points[i + 1];

      // Direction and perpendicular vectors for this segment.
      double dx = p1.dx - p0.dx;
      double dy = p1.dy - p0.dy;
      double len = sqrt(dx * dx + dy * dy);
      if (len == 0) continue;

      double tx = dx / len; // Tangent direction
      double ty = dy / len;
      double nx = -ty; // Normal (perpendicular) direction
      double ny = tx;

      int baseVertexIdx = rawVertices.length ~/ 2;

      // --- 1. Segment body (rectangular quad) --------------------------------
      rawVertices.addAll([p0.dx + nx * radius, p0.dy + ny * radius]);
      rawVertices.addAll([p0.dx - nx * radius, p0.dy - ny * radius]);
      rawVertices.addAll([p1.dx + nx * radius, p1.dy + ny * radius]);
      rawVertices.addAll([p1.dx - nx * radius, p1.dy - ny * radius]);

      indices.addAll([
        baseVertexIdx + 0,
        baseVertexIdx + 1,
        baseVertexIdx + 2,
        baseVertexIdx + 1,
        baseVertexIdx + 3,
        baseVertexIdx + 2,
      ]);

      // --- 2. Rounded start cap ---------------------------------------------
      int capStartCenterIdx = rawVertices.length ~/ 2;
      rawVertices.addAll([p0.dx, p0.dy]);

      double angleStart = atan2(ty, tx);
      for (int j = 0; j <= capSegments; j++) {
        double angle = angleStart + pi / 2 + (j * pi / capSegments);
        rawVertices.addAll([
          p0.dx + radius * cos(angle),
          p0.dy + radius * sin(angle),
        ]);
        if (j > 0) {
          int currIdx = rawVertices.length ~/ 2 - 1;
          indices.addAll([capStartCenterIdx, currIdx - 1, currIdx]);
        }
      }

      // --- 3. Rounded end cap -----------------------------------------------
      int capEndCenterIdx = rawVertices.length ~/ 2;
      rawVertices.addAll([p1.dx, p1.dy]);

      double angleEnd = atan2(ty, tx);
      for (int j = 0; j <= capSegments; j++) {
        double angle = angleEnd - pi / 2 + (j * pi / capSegments);
        rawVertices.addAll([
          p1.dx + radius * cos(angle),
          p1.dy + radius * sin(angle),
        ]);
        if (j > 0) {
          int currIdx = rawVertices.length ~/ 2 - 1;
          indices.addAll([capEndCenterIdx, currIdx - 1, currIdx]);
        }
      }
    }

    return Vertices.raw(
      VertexMode.triangles,
      Float32List.fromList(rawVertices),
      indices: Uint16List.fromList(indices),
    );
  }
}
