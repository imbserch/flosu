import 'package:flutter/services.dart';

class Interpolation {
  static List<double> barycentricWeights(List<Offset> points) {
    int n = points.length;
    List<double> weights = List.filled(n, 0.0);

    for (int i = 0; i < n; i++) {
      weights[i] = 1;

      for (int j = 0; j < n; j++) {
        if (i != j) {
          weights[i] *= (points[i].dx - points[j].dx);
        }
      }

      weights[i] = 1.0 / weights[i];
    }
    return weights;
  }

  static double barycentricLagrange(
    List<Offset> points,
    List<double> weights,
    double time,
  ) {
    if (points.isEmpty) throw Exception("Points must not be empty");
    if (points.length != weights.length) {
      throw Exception(
        "Points and Weights must contain the same number of elements",
      );
    }

    double numerator = 0.0;
    double denominator = 0.0;

    for (int i = 0; i < points.length; i++) {
      if (time == points[i].dx) return points[i].dy;

      double li = weights[i] / (time - points[i].dx);
      numerator += li * points[i].dy;
      denominator += li;
    }

    return numerator / denominator;
  }
}
