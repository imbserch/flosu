import 'package:flosu/core/extensions/ui.dart';
import 'package:flosu/shared/input/input.dart';
import 'package:flosu/shared/logging.dart';
import 'package:flosu/shared/router.dart' show rootNavigatorKey;
import 'package:flutter/gestures.dart' show GestureBinding, PointerEvent;
import 'package:flutter/services.dart' hide PointerEvent;
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef InputEventCallback = bool Function();

enum InputHandlerType { mouse, keyboard, all }

InputMouseEvent _pointerToInput(PointerEvent event) {
  final position = _pointerTransformOffset(event.position);

  return InputMouseEvent(position, .none, false);
}

InputKeyEvent _keyToInput(
  KeyEvent event,
  Set<LogicalKeyboardKey> lastPressedKeys,
) {
  final keyPressed = event is KeyDownEvent;

  bool pressed(LogicalKeyboardKey key) {
    if (event.logicalKey == key) return keyPressed;
    return lastPressedKeys.contains(key);
  }

  final isShiftPressed = pressed(.shiftLeft) || pressed(.shiftRight);
  final isControlPressed = pressed(.controlLeft) || pressed(.controlRight);
  final isAltPressed = pressed(.altLeft) || pressed(.altRight);

  return InputKeyEvent(
    event.logicalKey,
    keyPressed,
    isControlPressed,
    isShiftPressed,
    isAltPressed,
  );
}

Offset _pointerTransformOffset(Offset position) {
  final context = rootNavigatorKey.currentContext!;

  final scale = context.scale * context.pixelRatio;

  final scaledOffset = Offset(position.dx / scale, position.dy / scale);
  return scaledOffset;
}

class InputService with Logging {
  bool _initialized = false;

  InputKeyEvent? _lastKeyEvent;
  InputMouseEvent? _lastMouseEvent;

  final Set<LogicalKeyboardKey> _lastPressedKeys = {};

  final Map<InputHandlerType, List<InputEventCallback>> _handlers = {
    .mouse: [],
    .keyboard: [],
    .all: [],
  };

  Future<void> init() async {
    if (_initialized) return;

    requestLogger();

    GestureBinding.instance.pointerRouter.addGlobalRoute(_handlePointer);
    HardwareKeyboard.instance.addHandler(_handleKeyboard);

    _initialized = true;
  }

  void dispose() {
    _checkInitialized();
    removeLogger();

    for (final callbacks in _handlers.values) {
      callbacks.clear();
    }

    GestureBinding.instance.pointerRouter.removeGlobalRoute(_handlePointer);
    HardwareKeyboard.instance.removeHandler(_handleKeyboard);
  }

  void addHandler(InputHandlerType type, InputEventCallback callback) {
    // Add callback at the beginning of the list so that it is called first.
    _handlers[type]!.insert(0, callback);

    log("Added handler of type $type", level: .debug);
  }

  void removeHandler(InputHandlerType type, InputEventCallback callback) {
    _handlers[type]!.remove(callback);

    log("Removed handler of type $type", level: .debug);
  }

  /// Last keyboard event.
  InputKeyEvent get keyboard => _lastKeyEvent!;

  /// Last mouse event.
  InputMouseEvent get mouse => _lastMouseEvent!;

  void _handlePointer(PointerEvent event) {
    // Set event before dispatch to all handlers.
    _lastMouseEvent = _pointerToInput(event);

    // Call first only mouse handlers, then all handlers.
    for (final callback in _handlers[InputHandlerType.mouse]!) {
      if (callback()) return;
    }

    for (final callback in _handlers[InputHandlerType.all]!) {
      if (callback()) return;
    }
  }

  bool _handleKeyboard(KeyEvent event) {
    if (event is KeyRepeatEvent) return false;

    if (event is KeyDownEvent) {
      _lastPressedKeys.add(event.logicalKey);
    }

    if (event is KeyUpEvent) {
      _lastPressedKeys.remove(event.logicalKey);
    }
    // Update pressed keys after setting event.
    _updateKeys(event.logicalKey, event is KeyDownEvent);

    // Set event before dispatch to all handlers.
    _lastKeyEvent = _keyToInput(event, _lastPressedKeys);

    // Call first only keyboard handlers, then all handlers.
    for (final callback in _handlers[InputHandlerType.keyboard]!) {
      if (callback()) return true;
    }

    for (final callback in _handlers[InputHandlerType.all]!) {
      if (callback()) return true;
    }

    return false;
  }

  bool _updateKeys(LogicalKeyboardKey key, bool pressed) {
    if (pressed) return _lastPressedKeys.add(key);
    return _lastPressedKeys.remove(key);
  }

  void _checkInitialized() {
    const message = "Input service not initialized. Please call init() first";

    assert(_initialized, message);
    if (!_initialized) throw Exception(message);
  }
}

final inputProvider = Provider<InputService>((ref) {
  final service = InputService();
  ref.onDispose(service.dispose);

  return service;
});
