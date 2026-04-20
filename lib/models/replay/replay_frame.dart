import 'package:flutter/material.dart';
import 'package:flosu/core/enums.dart';

class ReplayFrame {
  ReplayFrame(this.time, this.pos, [this.keys = const []]);

  final int time;
  final Offset pos;

  final List<OsuKey> keys;
}
