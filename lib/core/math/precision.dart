import 'package:flosu/core/constants.dart';
import 'package:flutter/services.dart';

class Precision {
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
