import 'dart:ui' show Offset, Color;

import 'package:flosu/core/constants.dart';
import 'package:flosu/core/enums.dart';
import 'package:flosu/core/math/slider_path.dart';

import '../beatmap.dart';

part "hit_circle.dart";
part "slider.dart";
part "spinner.dart";

/// Base class for hit objects of the beatmap.
// Hierarchy of classes
// - HitObject
//    - HitCircle
//    - HitObjectWithEndTime
//       - Slider
//       - Spinner
sealed class HitObject {
  /// Fallback to playfield centre.
  Offset position = SPINNER_CENTRE;

  /// Time of object hit.
  int time = 0;

  Color? _color;
  int? _comboNumber;

  /// Color of object. Used by gameplay for drawing.
  Color color(Beatmap beatmap) => _color ??= beatmap.colors[0];

  /// Number of hit object.
  int comboNumber(Beatmap beatmap) => _comboNumber ??= 0;
}

/// Base class for hit objects with an end time.
sealed class HitObjectWithEndTime extends HitObject {
  /// The end time of object.
  int endTime = 0;

  /// Duration of object.
  int get duration => endTime - time;
}
