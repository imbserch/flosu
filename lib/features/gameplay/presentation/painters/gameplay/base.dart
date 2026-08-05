import 'package:flosu/shared/domain/mod/mod.dart';
import 'package:flosu/shared/domain/beatmap/beatmap.dart';
import 'package:flosu/shared/domain/beatmap/hit_object/hit_object.dart';
import 'package:flutter/material.dart' hide Slider;

part 'hit_objects/base.dart';

sealed class PlayfieldDrawable {
  PlayfieldDrawable();

  // Here is where you store your variables

  /// Checks if the object is expired and will no longer be rendered
  bool isExpired(double position) => false;

  /// Renders the object on the canvas
  void paint(Canvas c, double position) {
    if (isExpired(position)) return;
  }
}
