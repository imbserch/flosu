import 'package:flosu/models/beatmap/hit_objects.dart';
import 'package:flosu/models/mods/base.dart';
import 'package:flosu/models/storage/beatmap_metadata.dart';
import 'package:flutter/material.dart' hide Slider;

part 'hit_objects/base.dart';

sealed class PlayfieldDrawable {
  PlayfieldDrawable();

  // Here is where you store your variables

  /// Checks if the object is expired and will no longer be rendered
  bool isExpired(int position) => false;

  /// Renders the object on the canvas
  void paint(Canvas c, int position) {
    if (isExpired(position)) return;
  }
}
