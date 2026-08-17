import 'dart:math';
import 'dart:ui' show Offset;

import 'package:collection/collection.dart';
import 'package:flosu/core/constants.dart';
import 'package:flosu/core/enums.dart';
import 'package:flosu/core/math/circular_arc.dart';
import 'package:flosu/core/math/geometry.dart';

import 'path_approximator.dart';

class SliderPath {
  static List<double> getPathLengths(
    List<Offset> path,
    List<double>? cachedLengths,
  ) {
    // Don't reprocess path lengths if cached.
    if (cachedLengths != null) return cachedLengths;

    final List<double> accumulatedLengths = [0];

    for (int i = 1; i < path.length; i++) {
      accumulatedLengths.add(
        accumulatedLengths.last + (path[i] - path[i - 1]).distance,
      );
    }

    return accumulatedLengths;
  }

  static List<Offset> getPath(List<Offset> from, SliderCurve curveType) {
    final path = <Offset>[];

    final subPaths = CurveUtils.toSegments(from);

    for (final subPath in subPaths) {
      final res = getSubPath(subPath, curveType);

      // Skip the first point of the subpath if it is the same as the last point of the path to avoid duplicates.
      if (path.isNotEmpty && path.last == res.first) res.removeAt(0);

      path.addAll(res);
    }

    return path;
  }

  static List<Offset> getSubPath(List<Offset> subPath, SliderCurve curveType) {
    switch (curveType) {
      // Return points as is
      case SliderCurve.lineal:
        return PathApproximator.linearToPiecewiseLinear(subPath);

      // Use circular arc to approximate the curve
      case SliderCurve.perfect:
        if (subPath.length != 3) break;

        final arcProps = CircularArcProperties.fromControlPoints(subPath);
        if (!arcProps.isValid) break;

        // taken from https://github.com/ppy/osu-framework/blob/1201e641699a1d50d2f6f9295192dad6263d5820/osu.Framework/Utils/PathApproximator.cs#L181-L186
        final subPoints = (2 * arcProps.radius <= 0.1)
            ? 2
            : max(
                2,
                arcProps.thetaRange /
                    (2.0 * acos(1 - (0.1 / arcProps.radius))).ceil(),
              );

        if (subPoints >= 1000) break;

        final res = PathApproximator.circularArcToPiecewiseLinear(subPath);
        if (res.isEmpty) break;

        return res;
      // Use simplification of catmull curve
      case SliderCurve.catmull:
        final path = PathApproximator.catmullToPiecewiseLinear(subPath);
        List<Offset> optimizedPath = [];

        // Optimize path like osu!stable (ignoring optimizePath used in original sliderPath implementation)

        Offset? lastStart;

        for (int i = 0; i < path.length; i++) {
          if (lastStart == null) {
            optimizedPath.add(path[i]);
            lastStart = path[i];
            continue;
          }

          final distFromStart = (path[i] - lastStart).distance;

          if (distFromStart > 6 ||
              (i + 1) % CATMULL_SEGMENT_LENGTH == 0 ||
              i == path.length - 1) {
            optimizedPath.add(path[i]);
            lastStart = null;
          }
        }

        return optimizedPath;
      // Use default B-Spline to approximate the curve
      default:
        break;
    }

    return PathApproximator.bSplineToPiecewiseLinear(subPath, subPath.length);
  }

  static int indexAt(
    List<Offset> pathPoints,
    List<double> pathLengths,
    double t,
  ) {
    final clamped = t.clamp(0.0, 1.0);

    if (clamped == 0.0) return 0;
    if (clamped >= 1.0) return pathPoints.length - 1;

    final desiredLength = clamped * pathLengths.last;

    return pathLengths.lowerBound(desiredLength, (a, b) => a.compareTo(b));
  }

  static Offset pointAt(
    List<Offset> pathPoints,
    List<double> pathLengths,
    double t,
  ) {
    if (pathPoints.isEmpty) return Offset.zero;
    if (pathPoints.length == 1) return pathPoints.first;

    final clamped = t.clamp(0.0, 1.0);

    final totalLength = pathLengths.last;
    if (totalLength == 0) return pathPoints.first;

    final desiredLength = clamped * totalLength;
    final index = indexAt(pathPoints, pathLengths, t);

    if (index <= 0) return pathPoints.first;
    if (index >= pathPoints.length) return pathPoints.last;

    final double prevLength = pathLengths[index - 1];
    final double nextLength = pathLengths[index];
    final double segmentLength = nextLength - prevLength;

    final double tSegment = segmentLength == 0
        ? 0.0
        : (desiredLength - prevLength) / segmentLength;

    return Offset.lerp(
      pathPoints[index - 1],
      pathPoints[index],
      tSegment.clamp(0.0, 1.0),
    )!;
  }
}
