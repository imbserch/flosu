import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' hide PointerEvent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flosu/logic/services/input.dart';
import 'package:flosu/models/inputs/inputs.dart';

typedef ImmediateInputsCallback =
    void Function(Set<LogicalKeyboardKey> keys, PointerEvent? pointer);

typedef DelayedInputsCallback = void Function(InputEvents events);

class InputProvider extends Notifier<void> {
  late final InputService _service;
  late final Ticker _ticker;

  @override
  build() {
    _ticker = Ticker(_callDelayedHandlers)..start();
    _service = ref.read(inputService);
    _service.addHandler(_onEvent);

    ref.onDispose(() {
      _ticker.stop();
      _service.removeHandler(_onEvent);
      _service.dispose();
    });
  }

  //For passive listening
  final List<HardwareEvent> _storedEvents = [];

  //For active listening
  final Set<LogicalKeyboardKey> _pressedKeys = {};
  PointerEvent? _lastPointerEvent;

  final List<ImmediateInputsCallback> _inmediateHandlers = [];
  final List<DelayedInputsCallback> _delayedHandlers = [];

  //For active input events listening
  void addInmediateHandler(ImmediateInputsCallback callback) {
    _inmediateHandlers.add(callback);
  }

  void removeInmediateHandler(ImmediateInputsCallback callback) {
    _inmediateHandlers.remove(callback);
  }

  //For passive listening
  void addDelayedHandler(DelayedInputsCallback callback) {
    _delayedHandlers.add(callback);
  }

  void removeDelayedHandler(DelayedInputsCallback callback) {
    _delayedHandlers.remove(callback);
  }

  void _onEvent(HardwareEvent event) {
    //Store events for active listening
    if (event is PointerEvent) _lastPointerEvent = event;
    if (event is KeyboardEvent) {
      if (event.pressed) {
        _pressedKeys.add(event.key);
      } else {
        _pressedKeys.remove(event.key);
      }
    }

    //Call inmediate handlers
    _callImmediateHandlers();

    //Store events for passive listening
    _storedEvents.add(event);
  }

  void _callImmediateHandlers() {
    for (final inmediateHandler in _inmediateHandlers) {
      inmediateHandler(_pressedKeys, _lastPointerEvent);
    }
  }

  void _callDelayedHandlers(_) {
    //Don't update handlers if no new events fired
    if (_storedEvents.isEmpty) return;

    final latestEvents = InputEvents(
      List.from(_storedEvents.whereType<PointerEvent>()),
      List.from(_storedEvents.whereType<KeyboardEvent>()),
    );

    //Call all delayed handlers
    for (final delayedHandler in _delayedHandlers) {
      delayedHandler(latestEvents);
    }

    //Reset stored events
    _storedEvents.clear();
  }
}

final inputProvider = NotifierProvider(() => InputProvider());
