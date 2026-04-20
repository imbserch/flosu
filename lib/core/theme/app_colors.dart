import 'dart:ui';

abstract class AppColors {
  //Darker colors
  static const Color containerLowest = Color(0XFF0C0F10);
  static const Color containerLow = Color(0XFF171C1E);

  //Background
  static const Color background = Color(0XFF22282A);

  //Lighter colors
  static const Color container = Color(0XFF2E3538);
  static const Color containerHigh = Color(0XFF394246);

  static const Color red = Color(0xffff6666);

  /// A vibrant fuchsia often used for highlights.
  static const Color fucshia = Color(0xffD52EB1);
  static const Color pink = Color(0xfff668aa);
  static const Color purple = Color(0xff8c66ff);
  static const Color lightBlue = Color(0xff66ccff);
  static const Color green = Color(0xffb2ff66);
  static const Color yellow = Color(0xffFDD965);

  static Color middle(Color a, Color b) => Color.lerp(a, b, .5)!;
}
