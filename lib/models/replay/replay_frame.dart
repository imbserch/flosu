import 'package:flutter/material.dart';
import 'package:flosu/core/enums.dart';

/// Represents a single snapshot/frame of movement and key presses in a replay file.
///
/// Holds the timestamp [time] in milliseconds, the cursor coordinates [pos],
/// and the keys currently pressed [keys] during this frame.
class ReplayFrame {
  ReplayFrame(this.time, this.pos, [this.keys = const []]);

  final int time;
  final Offset pos;

  final List<OsuKey> keys;
}
