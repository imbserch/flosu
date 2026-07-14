import 'dart:math';
import 'dart:ui';

import 'package:flosu/core/constants.dart';

class VerticesUtils {
  static Vertices computeStrokeVertices(
    List<Offset> points,
    double strokeWidth,
  ) {
    final List<Offset> uniquePoints = [];
    for (final p in points) {
      if (uniquePoints.isEmpty ||
          (p - uniquePoints.last).distanceSquared > EPSILON) {
        uniquePoints.add(p);
      }
    }

    if (uniquePoints.isEmpty) {
      return Vertices(VertexMode.triangles, []);
    }

    final builder = MeshBuilder();

    if (uniquePoints.length == 1) {
      builder.addSector(uniquePoints[0], strokeWidth, 0.0, 2 * pi);
      return Vertices(
        VertexMode.triangles,
        builder.positions,
        indices: builder.indices,
      );
    }

    final List<double> angles = [];
    for (int i = 0; i < uniquePoints.length - 1; i++) {
      final diff = uniquePoints[i + 1] - uniquePoints[i];
      angles.add(diff.direction);
    }

    // Add start cap
    builder.addSector(
      uniquePoints[0],
      strokeWidth,
      angles[0] + pi / 2,
      angles[0] + 3 * pi / 2,
    );

    // Add end cap
    builder.addSector(
      uniquePoints.last,
      strokeWidth,
      angles.last - pi / 2,
      angles.last + pi / 2,
    );

    // Add segments
    for (int i = 0; i < uniquePoints.length - 1; i++) {
      final pStart = uniquePoints[i];
      final pEnd = uniquePoints[i + 1];
      final phi = angles[i];
      final cosPhiPlus = cos(phi + pi / 2);
      final sinPhiPlus = sin(phi + pi / 2);
      final cosPhiMinus = cos(phi - pi / 2);
      final sinPhiMinus = sin(phi - pi / 2);

      final vLs =
          pStart + Offset(cosPhiPlus * strokeWidth, sinPhiPlus * strokeWidth);
      final vRs =
          pStart + Offset(cosPhiMinus * strokeWidth, sinPhiMinus * strokeWidth);
      final vLe =
          pEnd + Offset(cosPhiPlus * strokeWidth, sinPhiPlus * strokeWidth);
      final vRe =
          pEnd + Offset(cosPhiMinus * strokeWidth, sinPhiMinus * strokeWidth);

      final int idxLs = builder.addVertex(vLs);
      final int idxRs = builder.addVertex(vRs);
      final int idxLe = builder.addVertex(vLe);
      final int idxRe = builder.addVertex(vRe);

      builder.addTriangle(idxLs, idxLe, idxRs);
      builder.addTriangle(idxLe, idxRe, idxRs);
    }

    // Add intermediate joins
    for (int i = 1; i < uniquePoints.length - 1; i++) {
      final phiPrev = angles[i - 1];
      final phiCurr = angles[i];
      double delta = phiCurr - phiPrev;
      while (delta > pi) {
        delta -= 2 * pi;
      }
      while (delta <= -pi) {
        delta += 2 * pi;
      }

      if (delta.abs() < EPSILON) continue;

      if (delta > 0) {
        builder.addSector(
          uniquePoints[i],
          strokeWidth,
          phiPrev - pi / 2,
          phiPrev - pi / 2 + delta,
        );
      } else {
        builder.addSector(
          uniquePoints[i],
          strokeWidth,
          phiPrev + pi / 2,
          phiPrev + pi / 2 + delta,
        );
      }
    }

    return Vertices(
      VertexMode.triangles,
      builder.positions,
      indices: builder.indices,
    );
  }
}

class MeshBuilder {
  final List<Offset> positions = [];
  final List<int> indices = [];

  int addVertex(Offset pos) {
    positions.add(pos);
    return positions.length - 1;
  }

  void addTriangle(int i1, int i2, int i3) {
    indices.add(i1);
    indices.add(i2);
    indices.add(i3);
  }

  void addSector(Offset center, double r, double startAngle, double endAngle) {
    final double angleSpan = endAngle - startAngle;
    if (angleSpan.abs() < EPSILON) return;

    // 15 degrees per step is a good heuristic: pi / 12
    const double stepAngle = pi / 12;
    final int steps = max(1, (angleSpan.abs() / stepAngle).round());
    final double dTheta = angleSpan / steps;

    final int centerIdx = addVertex(center);

    double currentAngle = startAngle;
    int prevOuterIdx = addVertex(
      center + Offset(cos(currentAngle) * r, sin(currentAngle) * r),
    );

    for (int step = 1; step <= steps; step++) {
      currentAngle = startAngle + step * dTheta;
      final int outerIdx = addVertex(
        center + Offset(cos(currentAngle) * r, sin(currentAngle) * r),
      );

      if (dTheta > 0) {
        addTriangle(centerIdx, prevOuterIdx, outerIdx);
      } else {
        addTriangle(centerIdx, outerIdx, prevOuterIdx);
      }
      prevOuterIdx = outerIdx;
    }
  }
}
