import 'dart:math';
import 'dart:ui';

/// A utility class to handle Bezier curve calculations, including
/// length approximation and point sampling using De Casteljau's algorithm.
class Bezier {
  /// Calculates the approximate length of a Bezier curve defined by [points].
  /// It first estimates the complexity to determine the number of steps
  /// needed for a more accurate linear approximation.
  static double getLength(List<Offset> points) {
    double polygonLen = 0;

    // Calculate the length of the control point polygon
    for (int i = 1; i < points.length; i++) {
      polygonLen += (points[i] - points[i - 1]).distance;
    }

    // Determine sampling steps based on the polygon length
    final steps = polygonLen / 4;

    double totalLen = 0;
    Offset lastPoint = points[0];

    // Sum the distances between sampled points along the curve
    for (int i = 1; i <= steps; i++) {
      final t = i / steps;
      Offset currentPoint = getPoint(points, t);
      totalLen += (currentPoint - lastPoint).distance;
      lastPoint = currentPoint;
    }

    return totalLen;
  }

  /// Calculates a specific point on the Bezier curve at parameter [t] (0.0 to 1.0).
  /// Uses De Casteljau's algorithm for numerical stability.
  static Offset getPoint(List<Offset> points, double t) {
    if (points.isEmpty) return Offset.zero;

    List<Offset> temp = List.from(points);
    int n = temp.length;

    // Iteratively interpolate between points
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

  /// Generates a list of points (a spline) representing the Bezier curve.
  /// [segments] determines the base resolution, and [threshold] ensures
  /// points are only added if they are far enough apart.
  static List<Offset> getSpline(
    List<Offset> points,
    int segments, [
    double threshold = 1.0,
  ]) {
    final multSegments = segments * 4;

    List<Offset> curve = [];

    // Sample points at regular intervals
    for (int i = 0; i <= multSegments; i++) {
      final t = i / multSegments;
      curve.add(getPoint(points, t));
    }

    final List<Offset> filtered = [curve.first];

    // Filter points based on the distance threshold to optimize the output
    for (int i = 1; i < curve.length; i++) {
      final current = curve[i];

      if ((current - filtered.last).distance >= threshold) {
        filtered.add(current);
      }
    }

    return filtered;
  }

  static List<Offset> filter(List<Offset> points, [double threshold = 1.0]) {
    List<Offset> filtered = [
      points.firstWhere((o) => !o.dx.isNaN && !o.dy.isNaN),
    ];

    for (int i = 1; i < points.length; i++) {
      final current = points[i];

      if (current.dx.isNaN || current.dy.isNaN) continue;
      if (current != filtered.last) {
        if ((filtered.last - current).distance > threshold) {
          filtered.add(current);
        }
      }
    }

    return filtered;
  }
}

/// A utility class for circle-based arc calculations, specifically for
/// arcs defined by three points.
class Arc {
  /// Internal method to calculate the geometry (center, radii, and angles)
  /// of an arc passing through three points. Returns null if points are collinear.
  static ({Offset center, List<double> radius, List<double> angles})? _getData(
    List<Offset> points,
  ) {
    final pX = points.map((p) => p.dx).toList();
    final pY = points.map((p) => p.dy).toList();

    // Determinant to check for collinearity
    final d =
        2 *
        (pX[0] * (pY[1] - pY[2]) +
            pX[1] * (pY[2] - pY[0]) +
            pX[2] * (pY[0] - pY[1]));

    if (d.abs() < 0.0001) return null;

    // Calculate center coordinates of the circle
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
    // Radii from center to each of the three points
    final radius = [
      (points[0] - center).distance,
      (points[1] - center).distance,
      (points[2] - center).distance,
    ];

    // Angles of the points relative to the center
    final angles = [
      atan2(pY[0] - cY, pX[0] - cX),
      atan2(pY[1] - cY, pX[1] - cX),
      atan2(pY[2] - cY, pX[2] - cX),
    ];

    // Normalize angles to ensure smooth interpolation
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

  /// Calculates a point on the arc at parameter [t].
  /// Interpolates both the radius and the angle for variable-radius arcs.
  static Offset getPoint(
    Offset center,
    List<double> radius,
    List<double> angles,
    double t,
  ) {
    double startRadius, endRadius, startAngle, endAngle, localT;

    // Determine which half of the three-point arc we are in
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

  /// Calculates the total arc length.
  /// Return null if the points are collinear
  static double? getLength(List<Offset> points) {
    final data = _getData(points);

    if (data == null) return null;

    // Arc length formula: L = radius * central_angle (theta)
    final sweepStart = (data.angles[1] - data.angles[0]).abs();
    final radiusStart = (data.radius[0] + data.radius[1]) / 2;
    final startMidLength = radiusStart * sweepStart;

    final sweepEnd = (data.angles[2] - data.angles[1]).abs();
    final radiusEnd = (data.radius[1] + data.radius[2]) / 2;
    final midEndLength = radiusEnd * sweepEnd;

    return startMidLength + midEndLength;
  }

  /// Generates a list of points representing the arc path.
  static List<Offset> getSpline(
    List<Offset> points,
    int segments, [
    double threshold = 1.0,
  ]) {
    List<Offset> arc = [];

    final data = _getData(points);

    if (data == null) return points;

    final multSegments = segments * 4;

    for (int i = 0; i <= multSegments; i++) {
      final t = i / multSegments;
      arc.add(getPoint(data.center, data.radius, data.angles, t));
    }

    final List<Offset> filtered = [arc.first];

    // Filter points based on the distance threshold to optimize the output
    for (int i = 1; i < arc.length; i++) {
      final current = arc[i];

      if ((current - filtered.last).distance >= threshold) {
        filtered.add(current);
      }
    }

    return filtered;
  }
}

/// A utility class for basic straight line calculations.
class Line {
  /// Returns the distance between two points.
  static double getLength(List<Offset> points) {
    return (points[0] - points[1]).distance;
  }

  /// Linear interpolation between point [a] and point [b] at parameter [t].
  static Offset getPoint(Offset a, Offset b, double t) {
    return Offset(a.dx + t * (b.dx - a.dx), a.dy + t * (b.dy - a.dy));
  }

  /// Generates a list of points forming a straight line divided into [segments].
  static List<Offset> getSpline(List<Offset> points, int segments) {
    final List<Offset> line = [];

    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      line.add(getPoint(points[0], points[1], t));
    }

    return line;
  }
}
