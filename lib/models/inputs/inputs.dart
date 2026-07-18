import 'package:flutter/services.dart';

/// A single batch of input events from both pointer and keyboard devices.
class InputEvents {
  InputEvents(this.pointer, this.keys);

  /// Constructs an empty event batch (no events this frame).
  InputEvents.empty() : pointer = [], keys = [];

  /// All pointer events recorded since the last batch.
  final List<PointerEvent> pointer;

  /// All keyboard events recorded since the last batch.
  final List<KeyboardEvent> keys;
}

/// Base class for all hardware-generated input events.
///
/// Each event records the exact [DateTime] it was created, allowing the
/// gameplay layer to reason about input timing relative to audio position.
sealed class HardwareEvent {
  HardwareEvent() : timestamp = DateTime.now();

  /// Wall-clock time when this event was created.
  final DateTime timestamp;
}

/// A pointer (mouse / tablet) movement or scroll event.
class PointerEvent extends HardwareEvent {
  PointerEvent(this.position, this.scroll, this.pressed) : super();

  /// Position of the pointer in the app's scaled coordinate space.
  ///
  /// Already divided by the global scale factor set in [InputService].
  final Offset position;

  /// Scroll delta for mouse wheel events; [Offset.zero] for move events.
  final Offset scroll;

  /// If the pointer is pressed (left click)
  final bool pressed;
}

/// A keyboard key press or release event.
class KeyboardEvent extends HardwareEvent {
  KeyboardEvent(this.key, this.pressed) : super();

  /// The logical key that changed state.
  final LogicalKeyboardKey key;

  /// `true` if the key was pressed, `false` if it was released.
  final bool pressed;
}

class KeysState {
  KeysState(
    this.keys, {
    this.control = false,
    this.alt = false,
    this.shift = false,
  });

  KeysState.empty() : this(const {});

  final Set<LogicalKeyboardKey> keys;
  final bool control;
  final bool alt;
  final bool shift;
}
