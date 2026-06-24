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
  PointerEvent(this.position, this.scroll) : super();

  /// Position of the pointer in the app's scaled coordinate space.
  ///
  /// Already divided by the global scale factor set in [InputService].
  final Offset position;

  /// Scroll delta for mouse wheel events; [Offset.zero] for move events.
  final Offset scroll;
}

/// A keyboard key press or release event.
class KeyboardEvent extends HardwareEvent {
  KeyboardEvent(this.key, this.pressed) : super();

  /// The logical key that changed state.
  final LogicalKeyboardKey key;

  /// `true` if the key was pressed, `false` if it was released.
  final bool pressed;
}

/// A simulated pointer event derived from a [ReplayFrame].
///
/// Used to animate the replay cursor on the playfield without routing through
/// the real hardware event pipeline.
class ReplayFrameEvent extends HardwareEvent {
  ReplayFrameEvent(this.time, this.position) : super();

  /// Replay frame timestamp in milliseconds.
  final int time;

  /// Cursor position in playfield coordinates.
  final Offset position;
}
