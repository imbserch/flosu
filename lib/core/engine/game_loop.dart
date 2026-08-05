import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Callback function that receives the time delta between ticks.
typedef TickHandlerCallback = void Function(double delta);

/// A centralized scheduler service that manages the core game loop.
class GameLoop {
  GameLoop._() {
    _init();
  }

  static final GameLoop _instance = GameLoop._();

  final List<TickHandlerCallback> _handlers = [];

  double _lastTickedTime = 0;
  late final Ticker _ticker;
  late final Stopwatch _stopwatch;

  FrameTiming? _frameTiming;

  void _init() {
    _ticker = Ticker(_process);
    _stopwatch = Stopwatch()..start();
    SchedulerBinding.instance.addTimingsCallback(_onTimingsCallback);
  }

  /// This method must be called when the application is closing.
  // Actually, you can ignore it for now because this is a Singleton
  void dispose() {
    _stopwatch
      ..stop()
      ..reset();
    _ticker.stop();
    _handlers.clear();
    SchedulerBinding.instance.removeTimingsCallback(_onTimingsCallback);
  }

  void _onTimingsCallback(List<FrameTiming> timings) {
    _frameTiming = timings.last;
  }

  /// Subscribes a callback to the game loop.
  ///
  /// The callback will be invoked on every tick of the game loop.
  static void subscribe(TickHandlerCallback callback) {
    if (!_instance._handlers.contains(callback)) {
      _instance._handlers.add(callback);
    }

    // Start the ticker if it is not already running.
    if (_instance._handlers.isNotEmpty && !_instance._ticker.isActive) {
      _instance._ticker.start();
    }
  }

  /// Unsubscribes a callback from the game loop.
  static void unsubscribe(TickHandlerCallback handler) {
    _instance._handlers.remove(handler);

    // Stop the ticker if there are no more subscribers.
    if (_instance._handlers.isEmpty && _instance._ticker.isActive) {
      _instance._ticker.stop();
    }
  }

  /// Gets the current time of the game loop in milliseconds.
  ///
  /// Useful for syncing game events, audio playback, or any other time-based logic.
  static int get time => _instance._stopwatch.elapsedMilliseconds;

  static FrameTiming? get frameTiming => _instance._frameTiming;

  /// Processes a tick of the game loop.
  void _process(Duration tick) {
    // Get the delta time between ticks (in milliseconds).
    // Using microseconds instead of milliseconds to avoid precision loss
    // (1 millisecond = 1000 microseconds, so the result is still in milliseconds).
    final now = _stopwatch.elapsedMicroseconds / 1000;
    final delta = now - _lastTickedTime;

    // Notify all registered handlers on a copy of the list to prevent
    // ConcurrentModificationError if callbacks subscribe/unsubscribe during iteration.
    final handlers = List<TickHandlerCallback>.of(_handlers);

    for (final callback in handlers) {
      if (_handlers.contains(callback)) {
        callback(delta);
      }

      _lastTickedTime = now;
    }
  }
}

mixin GameLoopListener<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    GameLoop.subscribe(process);
  }

  @override
  void dispose() {
    GameLoop.unsubscribe(process);
    super.dispose();
  }

  void process(double delta);

  int get time => GameLoop.time;

  FrameTiming? get frameTiming => GameLoop.frameTiming;
}
