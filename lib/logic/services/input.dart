import 'package:flutter/gestures.dart' as gestures;
import 'package:flutter/rendering.dart' hide PointerEvent;
import 'package:flutter/services.dart' hide PointerEvent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flosu/core/extensions/ui.dart';
import 'package:flosu/models/inputs/inputs.dart';
import 'package:flosu/logic/providers/router.dart';

/// Type alias for a raw hardware-event handler.
typedef RawInputsHandler = void Function(HardwareEvent event);

/// Low-level input aggregator that wraps Flutter's global pointer and keyboard
/// event routes and forwards them to registered [RawInputsHandler] callbacks.
///
/// [InputService] operates as a singleton. It hooks into the framework at
/// construction time and remains active for the lifetime of the app.
/// Consumers should call [addHandler] / [removeHandler] rather than
/// accessing the framework APIs directly.
class InputService {
  InputService._() {
    _init();
  }

  static final InputService _instance = InputService._();

  static InputService get instance => _instance;

  final List<RawInputsHandler> _rawHandlers = [];

  /// Registers the global pointer route and keyboard handler.
  void _init() {
    gestures.GestureBinding.instance.pointerRouter.addGlobalRoute(
      _handlePointer,
    );
    HardwareKeyboard.instance.addHandler(_handleKeyboard);
  }

  /// Removes all global routes and clears the handler list.
  ///
  /// Should be called when the app is shutting down to avoid dangling
  /// references in the Flutter framework.
  void dispose() {
    _rawHandlers.clear();

    gestures.GestureBinding.instance.pointerRouter.removeGlobalRoute(
      _handlePointer,
    );
    HardwareKeyboard.instance.removeHandler(_handleKeyboard);
  }

  /// Converts a raw Flutter [gestures.PointerEvent] into a scaled [PointerEvent]
  /// and broadcasts it to all registered handlers.
  ///
  /// The position is divided by the app's combined scale × pixel-ratio factor
  /// so that coordinates match the 640×480 virtual resolution used everywhere.
  void _handlePointer(gestures.PointerEvent event) {
    final scale =
        rootNavigatorKey.currentContext!.scale *
        rootNavigatorKey.currentContext!.pixelRatio;

    final position = event.position;

    final pressed = event is gestures.PointerDownEvent;

    final scroll = event is gestures.PointerScrollEvent
        ? event.scrollDelta
        : Offset.zero;

    final scaledOffset = Offset(position.dx / scale, position.dy / scale);

    final pointerEvent = PointerEvent(scaledOffset, scroll, pressed);

    for (final handler in _rawHandlers) {
      handler(pointerEvent);
    }
  }

  /// Converts a raw [KeyEvent] into a [KeyboardEvent] and broadcasts it.
  ///
  /// [KeyRepeatEvent]s are ignored — only presses and releases are forwarded.
  bool _handleKeyboard(KeyEvent event) {
    if (event is KeyRepeatEvent) return false;
    final keyEvent = KeyboardEvent(event.logicalKey, event is KeyDownEvent);

    for (final handler in _rawHandlers) {
      handler(keyEvent);
    }

    return false;
  }

  /// Registers a [handler] to receive all future hardware events.
  void addHandler(RawInputsHandler handler) {
    _rawHandlers.add(handler);
  }

  /// Removes a previously registered [handler].
  void removeHandler(RawInputsHandler handler) {
    _rawHandlers.remove(handler);
  }
}

/// Global provider that exposes the [InputService] singleton.
final inputService = Provider<InputService>((_) => InputService.instance);
