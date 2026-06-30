import 'package:flosu/core/enums.dart';
import 'package:flosu/logic/services/game_loop.dart';
import 'package:flutter/services.dart' hide PointerEvent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flosu/logic/services/input.dart';
import 'package:flosu/models/inputs/inputs.dart';
import 'package:flosu/models/inputs/timings.dart';

export 'package:flosu/models/inputs/timings.dart';

/// Signature for a callback that receives the current key state and the latest
/// pointer event immediately after a hardware event fires.
typedef ImmediateInputsCallback =
    void Function(Set<LogicalKeyboardKey> keys, PointerEvent? pointer);

/// Signature for a callback that receives a batch of events accumulated since
/// the last frame tick.
typedef DelayedInputsCallback = void Function(InputEvents events);

/// Signature for a callback that receives the input timings.
typedef InputTimingsCallback = void Function(InputTimings timings);


/// Riverpod provider that bridges [InputService] hardware events to higher-level
/// consumers in the widget tree.
///
/// [InputProvider] offers two subscription models:
///
/// **Immediate** (`addInmediateHandler`): The callback is invoked on every
/// hardware event with the current pressed-key set and the latest pointer
/// position. Use for latency-sensitive gameplay code such as hit detection.
///
/// **Delayed** (`addDelayedHandler`): Events are accumulated until the next
/// frame tick, then delivered in bulk as an [InputEvents] batch. Use for
/// UI interactions where frame-rate synchronisation is preferred over raw speed.
class InputProvider extends Notifier<void> {
  late final InputService _service;

  final List<Duration> _immediateEventsDurations = [];
  final List<Duration> _delayedEventsDurations = [];

  @override
  build() {
    final gameLoop = ref.read(gameLoopService);

    gameLoop.subscribe(TickerPhase.input, _callDelayedHandlers);
    gameLoop.subscribe(TickerPhase.logic, _onTimingTick);

    _service = ref.read(inputService);
    _service.addHandler(_onEvent);

    ref.onDispose(() {
      gameLoop.unsubscribe(TickerPhase.input, _callDelayedHandlers);
      gameLoop.unsubscribe(TickerPhase.logic, _onTimingTick);

      _service.removeHandler(_onEvent);
      _service.dispose();
    });
  }

  // Accumulated events waiting to be delivered to delayed handlers.
  final List<PointerEvent> _storedPointerEvents = [];
  final List<KeyboardEvent> _storedKeyboardEvents = [];

  // Current pressed-key state for immediate handlers.
  final Set<LogicalKeyboardKey> _pressedKeys = {};
  PointerEvent? _lastPointerEvent;

  final List<ImmediateInputsCallback> _inmediateHandlers = [];
  final List<DelayedInputsCallback> _delayedHandlers = [];

  final List<InputTimingsCallback> _timingHandlers = [];

  // ---------------------------------------------------------------------------
  // Subscription management
  // ---------------------------------------------------------------------------

  /// Registers [callback] to be called on every hardware event.
  ///
  /// The callback receives the full set of currently pressed keys and the
  /// most recent pointer position.
  void addInmediateHandler(ImmediateInputsCallback callback) {
    _inmediateHandlers.add(callback);
  }

  /// Removes a previously registered immediate handler.
  void removeInmediateHandler(ImmediateInputsCallback callback) {
    _inmediateHandlers.remove(callback);
  }

  /// Registers [callback] to receive batched events once per frame.
  void addDelayedHandler(DelayedInputsCallback callback) {
    _delayedHandlers.add(callback);
  }

  /// Removes a previously registered delayed handler.
  void removeDelayedHandler(DelayedInputsCallback callback) {
    _delayedHandlers.remove(callback);
  }

  /// Registers [callback] to receive input timings once per frame.
  void addTimingsHandler(InputTimingsCallback callback) {
    _timingHandlers.add(callback);
  }

  /// Removes a previously registered timings handler.
  void removeTimingsHandler(InputTimingsCallback callback) {
    _timingHandlers.remove(callback);
  }

  // ---------------------------------------------------------------------------
  // Event processing
  // ---------------------------------------------------------------------------

  /// Processes an incoming [HardwareEvent] from [InputService].
  void _onEvent(HardwareEvent event) {
    // Update live key and pointer state for immediate handlers.
    if (event is PointerEvent) {
      _lastPointerEvent = event;
      if (_delayedHandlers.isNotEmpty) {
        _storedPointerEvents.add(event);
      }
    }
    if (event is KeyboardEvent) {
      if (event.pressed) {
        _pressedKeys.add(event.key);
      } else {
        _pressedKeys.remove(event.key);
      }
      if (_delayedHandlers.isNotEmpty) {
        _storedKeyboardEvents.add(event);
      }
    }

    _callImmediateHandlers();
  }

  /// Notifies all immediate handlers with the current input state.
  void _callImmediateHandlers() {
    final sw = Stopwatch()..start();

    for (final handler in _inmediateHandlers) {
      handler(_pressedKeys, _lastPointerEvent);
    }

    sw.stop();
    _immediateEventsDurations.add(sw.elapsed);
  }

  /// Called once per frame by the [_ticker] to flush accumulated events
  /// to all delayed handlers and clear the buffer.
  void _callDelayedHandlers(_) {
    if (_storedPointerEvents.isEmpty && _storedKeyboardEvents.isEmpty) return;

    final sw = Stopwatch()..start();

    // Only call handlers if there are any registered.
    if (_delayedHandlers.isNotEmpty) {
      final latestEvents = InputEvents(
        List.of(_storedPointerEvents),
        List.of(_storedKeyboardEvents),
      );

      for (final handler in _delayedHandlers) {
        handler(latestEvents);
      }

      _storedPointerEvents.clear();
      _storedKeyboardEvents.clear();
    }

    sw.stop();
    _delayedEventsDurations.add(sw.elapsed);
  }

  void _onTimingTick(_) {
    if (_timingHandlers.isEmpty) return;

    final timings = InputTimings(
      delayedEventsDuration: _delayedEventsDurations,
      immediateEventsDuration: _immediateEventsDurations,
    );

    for (final handler in _timingHandlers) {
      handler(timings);
    }

    _immediateEventsDurations.clear();
    _delayedEventsDurations.clear();
  }
}

/// Global provider for [InputProvider].
final inputProvider = NotifierProvider(() => InputProvider());
