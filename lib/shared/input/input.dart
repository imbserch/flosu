import 'package:flutter/services.dart' show LogicalKeyboardKey, Offset;

enum MouseScrollDirection { up, down, none }

abstract class InputEvent {
  InputEvent(this.pressed);

  final bool pressed;
}

class InputMouseEvent extends InputEvent {
  InputMouseEvent(this.position, this.scroll, super.pressed);

  final Offset position;
  final MouseScrollDirection scroll;
}

class InputKeyEvent extends InputEvent {
  InputKeyEvent(
    this.key,
    super.pressed,
    this.controlPressed,
    this.shiftPressed,
    this.altPressed,
  );

  final LogicalKeyboardKey key;

  final bool controlPressed;
  final bool shiftPressed;
  final bool altPressed;
}
