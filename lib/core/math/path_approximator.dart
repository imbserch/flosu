import 'dart:math';
import 'package:flosu/core/constants.dart';
import 'package:flosu/core/math/circular_arc.dart';
import 'package:flosu/core/math/interpolation.dart';
import 'package:flutter/services.dart';

class PathApproximator {
  static List<Offset> bezierToPiecewiseLinear(List<Offset> controlPoints) {
    return bSplineToPiecewiseLinear(
      controlPoints,
      max(1, controlPoints.length - 1),
    );
  }

  static List<Offset> bSplineToPiecewiseLinear(
    List<Offset> controlPoints,
    int degree,
  ) {
    if (controlPoints.length < 2) {
      return controlPoints.isEmpty ? [] : [controlPoints[0]];
    }

    degree = min(degree, controlPoints.length - 1);

    final List<Offset> output = [];
    final int pointCount = controlPoints.length - 1;

    List<List<Offset>> toFlatten = _bSplineToBezier(controlPoints, degree);
    List<List<Offset>> freeBuffers = [];

    List<Offset> buff1 = List.filled(degree + 1, .zero);
    List<Offset> buff2 = List.filled(degree * 2 + 1, .zero);

    List<Offset> leftChild = buff2;

    while (toFlatten.isNotEmpty) {
      final parent = toFlatten.removeLast();

      if (_bezierIsFlatEnough(parent)) {
        _bezierApproximate(parent, output, buff1, buff2, degree + 1);
        freeBuffers.add(parent);
        continue;
      }

      List<Offset> rightChild = freeBuffers.isNotEmpty
          ? freeBuffers.removeLast()
          : List.filled(degree + 1, .zero);

      _bezierSubdivide(parent, leftChild, rightChild, buff1, degree + 1);

      for (int i = 0; i < degree + 1; ++i) {
        parent[i] = leftChild[i];
      }

      toFlatten.add(rightChild);
      toFlatten.add(parent);
    }

    output.add(controlPoints[pointCount]);
    return output;
  }

  static List<List<Offset>> _bSplineToBezier(
    List<Offset> controlPoints,
    int degree,
  ) {
    List<List<Offset>> output = [];

    final internalDegree = min(degree, controlPoints.length - 1);

    int pointCount = controlPoints.length - 1;
    List<Offset> points = List.from(controlPoints);

    if (degree == pointCount) {
      output.add(points);
    } else {
      for (int i = 0; i < pointCount - internalDegree; i++) {
        final List<Offset> subBezier = List.filled(degree + 1, .zero);
        subBezier[0] = points[i];

        for (int j = 0; j < degree - 1; j++) {
          subBezier[j + 1] = points[i + 1];

          for (int k = 1; k < internalDegree - j; k++) {
            final l = min(k, pointCount - degree - i).toDouble();

            points[i + k] = ((points[i + k] * l) + points[i + k + 1]) / (l + 1);
          }
        }

        subBezier[degree] = points[i + 1];
        output.add(subBezier);
      }

      output.add(points.sublist(pointCount - degree));
      output = output.reversed.toList();
    }

    return output;
  }

  static List<Offset> catmullToPiecewiseLinear(List<Offset> controlPoints) {
    List<Offset> output = List.filled(
      (controlPoints.length - 1) * CATMULL_DETAIL * 2,
      .zero,
    );

    for (int i = 0; i < controlPoints.length; ++i) {
      var v1 = i > 0 ? controlPoints[i - 1] : controlPoints[i];
      var v2 = controlPoints[i];
      var v3 = i < controlPoints.length - 1
          ? controlPoints[i + 1]
          : v2 + v2 - v1;
      var v4 = i < controlPoints.length - 1
          ? controlPoints[i + 2]
          : v3 + v3 - v2;

      for (int c = 0; c < CATMULL_DETAIL; c++) {
        output.add(_findCatmullPoint(v1, v2, v3, v4, c / CATMULL_DETAIL));
        output.add(_findCatmullPoint(v1, v2, v3, v4, (c + 1) / CATMULL_DETAIL));
      }
    }

    return output;
  }

  static List<Offset> circularArcToPiecewiseLinear(List<Offset> points) {
    final arcProps = CircularArcProperties.fromControlPoints(points);

    if (!arcProps.isValid) return bezierToPiecewiseLinear(points);

    final amountPoints = 2 * arcProps.radius <= CIRCULAR_ARC_TOLERANCE
        ? 2
        : max(
            2,
            (arcProps.thetaRange /
                (2 * acos(1 - CIRCULAR_ARC_TOLERANCE / arcProps.radius))),
          );

    List<Offset> output = [];

    for (int i = 0; i < amountPoints; ++i) {
      final fract = i / (amountPoints - 1);
      final theta =
          arcProps.thetaStart +
          arcProps.direction * fract * arcProps.thetaRange;

      final o = Offset(cos(theta), sin(theta)) * arcProps.radius;
      output.add(arcProps.centre + o);
    }

    return output;
  }

  static List<Offset> linearToPiecewiseLinear(List<Offset> points) {
    return List.from(points);
  }

  static List<Offset> lagrangePolynomialToPiecewiseLinear(List<Offset> points) {
    List<Offset> output = [];

    List<double> weights = Interpolation.barycentricWeights(points);

    double minX = points[0].dx;
    double maxX = points[0].dx;

    for (int i = 1; i < points.length; ++i) {
      minX = min(minX, points[i].dx);
      maxX = points[i].dx;
    }

    final dx = maxX - minX;

    for (int i = 0; i < LAGRANGE_STEPS; ++i) {
      final x = minX + dx / (LAGRANGE_STEPS - 1) * i;
      final y = Interpolation.barycentricLagrange(points, weights, x);

      output.add(Offset(x, y));
    }

    return output;
  }

  static List<Offset> piecewiseLinearToBezier(
    List<Offset> path,
    int controlPoints, {
    int numTestPoints = 100,
    int maxIterations = 100,
    double learningRate = 8,
    double b1 = 0.8,
    double b2 = 0.99,
    List<Offset>? initialControlPoints,
  }) {
    return List.from(path);
  }

  static bool _bezierIsFlatEnough(List<Offset> controlPoints) {
    for (int i = 1; i < controlPoints.length - 1; i++) {
      final previous = controlPoints[i - 1];
      final current = controlPoints[i];
      final next = controlPoints[i + 1];

      final distanceSq = (previous - (current * 2) + next).distanceSquared;

      final threshold = 4 * pow(BEZIER_TOLERANCE, 2.0);

      if (distanceSq > threshold) return false;
    }

    return true;
  }

  static void _bezierApproximate(
    List<Offset> controlPoints,
    List<Offset> output,
    List<Offset> buff1,
    List<Offset> buff2,
    int count,
  ) {
    List<Offset> l = buff2;
    List<Offset> r = buff1;

    _bezierSubdivide(controlPoints, l, r, buff1, count);

    for (int i = 0; i < count - 1; ++i) {
      l[count + i] = r[i + 1];
    }

    output.add(controlPoints[0]);

    for (int i = 1; i < count - 1; ++i) {
      int index = 2 * i;
      Offset p = (l[index - 1] + (l[index] * 2) + l[index + 1]) * 0.25;

      output.add(p);
    }
  }

  static void _bezierSubdivide(
    List<Offset> controlPoints,
    List<Offset> l,
    List<Offset> r,
    List<Offset> subdivisionBuffer,
    int count,
  ) {
    final midPoints = subdivisionBuffer;

    for (int i = 0; i < count; ++i) {
      midPoints[i] = controlPoints[i];
    }

    for (int i = 0; i < count; i++) {
      l[i] = midPoints[0];
      r[count - i - 1] = midPoints[count - i - 1];

      for (int j = 0; j < count - i - 1; j++) {
        midPoints[j] = (midPoints[j] + midPoints[j + 1]) / 2;
      }
    }
  }

  static Offset _findCatmullPoint(
    Offset v1,
    Offset v2,
    Offset v3,
    Offset v4,
    double t,
  ) {
    final t2 = pow(t, 2);
    final t3 = t * t2;

    final x =
        0.5 *
        (2 * v2.dx +
            (-v1.dx + v3.dx) * t +
            (2 * v1.dx - 5 * v2.dx + 4 * v3.dx - v4.dx) * t2 +
            (-v1.dx + 3 * v2.dx - 3 * v3.dx + v4.dx) * t3);

    final y =
        0.5 *
        (2 * v2.dy +
            (-v1.dy + v3.dy) * t +
            (2 * v1.dy - 5 * v2.dy + 4 * v3.dy - v4.dy) * t2 +
            (-v1.dy + 3 * v2.dy - 3 * v3.dy + v4.dy) * t3);

    return Offset(x, y);
  }
}
