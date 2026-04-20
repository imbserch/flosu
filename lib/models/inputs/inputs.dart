import 'package:flutter/services.dart';

class InputEvents {
  InputEvents(this.pointer, this.keys);

  InputEvents.empty() : pointer = [], keys = [];

  final List<PointerEvent> pointer;
  final List<KeyboardEvent> keys;
}

sealed class HardwareEvent {
  HardwareEvent() : timestamp = DateTime.now();

  final DateTime timestamp;
}

class PointerEvent extends HardwareEvent {
  PointerEvent(this.position, this.scroll) : super();

  final Offset position;
  final Offset scroll;
}

class KeyboardEvent extends HardwareEvent {
  KeyboardEvent(this.key, this.pressed) : super();

  final LogicalKeyboardKey key;
  final bool pressed;
}
