import 'package:flutter/services.dart';

class Precision {
  // ignore: constant_identifier_names
  static const EPSILON = 1e-7;

  static bool almostEquals(
    Offset a,
    Offset b, [
    double acceptableDifference = EPSILON,
  ]) {
    final almostEqualsX = almostDoubleEquals(a.dx, b.dx, acceptableDifference);
    final almostEqualsY = almostDoubleEquals(a.dy, b.dy, acceptableDifference);

    return almostEqualsX && almostEqualsY;
  }

  static bool almostDoubleEquals(
    double a,
    double b, [
    double acceptableDifference = EPSILON,
  ]) => (a - b).abs() <= acceptableDifference;
}
