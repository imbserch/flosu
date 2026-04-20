import 'package:flutter/gestures.dart' as gestures;
import 'package:flutter/services.dart' hide PointerEvent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flosu/core/extensions.dart';
import 'package:flosu/models/inputs/inputs.dart';
import 'package:flosu/logic/providers/router.dart';

typedef RawInputsHandler = void Function(HardwareEvent event);

class InputService {
  InputService._() {
    _init();
  }

  static final InputService _instance = InputService._();

  static InputService get instance => _instance;

  final List<RawInputsHandler> _rawHandlers = [];

  void _init() {
    gestures.GestureBinding.instance.pointerRouter.addGlobalRoute(
      _handlePointer,
    );
    HardwareKeyboard.instance.addHandler(_handleKeyboard);
  }

  void dispose() {
    _rawHandlers.clear();

    gestures.GestureBinding.instance.pointerRouter.removeGlobalRoute(
      _handlePointer,
    );
    HardwareKeyboard.instance.removeHandler(_handleKeyboard);
  }

  void _handlePointer(gestures.PointerEvent event) {
    final scale =
        rootNavigatorKey.currentContext!.scale *
        rootNavigatorKey.currentContext!.pixelRatio;
    final position = event.position;
    final scroll = event is gestures.PointerScrollEvent
        ? event.scrollDelta
        : Offset.zero;

    final scaledOffset = Offset(position.dx / scale, position.dy / scale);

    final pointerEvent = PointerEvent(scaledOffset, scroll);

    for (final handler in _rawHandlers) {
      handler(pointerEvent);
    }
  }

  bool _handleKeyboard(KeyEvent event) {
    if (event is KeyRepeatEvent) return false;
    final keyEvent = KeyboardEvent(event.logicalKey, event is KeyDownEvent);

    for (final handler in _rawHandlers) {
      handler(keyEvent);
    }

    return false;
  }

  void addHandler(RawInputsHandler handler) {
    _rawHandlers.add(handler);
  }

  void removeHandler(RawInputsHandler handler) {
    _rawHandlers.remove(handler);
  }
}

final inputService = Provider<InputService>((_) => InputService.instance);
