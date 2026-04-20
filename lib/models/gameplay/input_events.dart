import 'package:flutter/material.dart';
import 'package:flosu/models/replay/replay_frame.dart';

//TODO: CONSIDER REMOVE THIS AFTER MIGRATION
class PointerEventWithTimestamp {
  PointerEventWithTimestamp(this.event)
    : timestamp = DateTime.now().millisecondsSinceEpoch;

  PointerEventWithTimestamp.fromFrame(ReplayFrame frame)
    : event = PointerMoveEvent(position: frame.pos),
      timestamp = DateTime.now().millisecondsSinceEpoch;
  final PointerEvent event;
  final int timestamp;
}
