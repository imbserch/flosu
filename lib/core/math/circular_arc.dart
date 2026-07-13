import 'dart:math';
import 'package:flosu/core/math/precision.dart';
import 'package:flutter/services.dart';

class CircularArcProperties {
  CircularArcProperties._(
    this.isValid,
    this.thetaStart,
    this.thetaRange,
    this.direction,
    this.radius,
    this.centre,
  );

  static CircularArcProperties fromControlPoints(List<Offset> points) {
    final a = points[0];
    final b = points[1];
    final c = points[2];

    if (Precision.almostDoubleEquals(
      0,
      (b.dy - a.dy) * (c.dx - a.dx) - (b.dx - a.dx) * (c.dy - a.dy),
    )) {
      return CircularArcProperties._(false, 0, 0, 0, 0, .zero);
    }

    double d =
        2 *
        (a.dx * (b.dy - c.dy) + b.dx * (c.dy - a.dy) + c.dx * (a.dy - b.dy));

    double aSq = a.distanceSquared;
    double bSq = b.distanceSquared;
    double cSq = c.distanceSquared;

    Offset centre =
        Offset(
          aSq * (b - c).dy + bSq * (c - a).dy + cSq * (a - b).dy,
          aSq * (c - b).dx + bSq * (a - c).dx + cSq * (b - a).dx,
        ) /
        d;

    final dA = a - centre;
    final dC = c - centre;

    final radius = dA.distance;

    final thetaStart = atan2(dA.dy, dA.dx);
    double thetaEnd = atan2(dC.dy, dC.dx);

    while (thetaEnd < thetaStart) {
      thetaEnd += 2 * pi;
    }

    double direction = 1;
    double thetaRange = thetaEnd - thetaStart;

    Offset orthoAtoC = c - a;
    orthoAtoC = Offset(orthoAtoC.dy, -orthoAtoC.dx);

    final bMinusA = b - a;
    final dot = (orthoAtoC.dx * bMinusA.dx) + (orthoAtoC.dy * bMinusA.dy);

    if (dot < 0) {
      direction = -direction;
      thetaRange = 2 * pi - thetaRange;
    }

    return CircularArcProperties._(
      true,
      thetaStart,
      thetaRange,
      direction,
      radius,
      centre,
    );
  }

  final bool isValid;
  final double thetaStart;
  final double thetaRange;
  final double direction;
  final double radius;
  final Offset centre;
}
