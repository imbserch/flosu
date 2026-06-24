import 'package:flosu/core/extensions.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef TickHandlerCallback = void Function(Duration tick);

// TODO: Move this outside this file
enum TickerPhase { input, logic, visual }

class GameLoopService {
  GameLoopService._() {
    _init();
  }

  static final GameLoopService _instance = GameLoopService._();

  static GameLoopService get instance => _instance;

  final List<TickHandlerCallback> _inputHandlers = [];
  final List<TickHandlerCallback> _logicHandlers = [];
  final List<TickHandlerCallback> _visualHandlers = [];

  int _handlers = 0;

  late final Ticker _ticker;

  void _init() {
    _ticker = Ticker(_process);
  }

  void subscribe(TickerPhase phase, TickHandlerCallback handler) {
    switch (phase) {
      case TickerPhase.input:
        _inputHandlers.add(handler);
        break;
      case TickerPhase.logic:
        _logicHandlers.add(handler);
        break;
      case TickerPhase.visual:
        _visualHandlers.add(handler);
        break;
    }

    _handlers++;

    if (_handlers != 0 && !_ticker.isActive) _ticker.start();
  }

  void unsubscribe(TickerPhase phase, TickHandlerCallback handler) {
    switch (phase) {
      case TickerPhase.input:
        _inputHandlers.remove(handler);
        break;
      case TickerPhase.logic:
        _logicHandlers.remove(handler);
        break;
      case TickerPhase.visual:
        _visualHandlers.remove(handler);
        break;
    }

    _handlers--;

    if (_handlers == 0 && _ticker.isActive) _ticker.stop();
  }

  // Time processing <=10 handlers: 0.075 ms
  void _process(Duration tick) {
    for (final input in _inputHandlers) {
      input(tick);
    }

    for (final logic in _logicHandlers) {
      logic(tick);
    }

    for (final visual in _visualHandlers) {
      visual(tick);
    }
  }

  void dispose() {
    _ticker.stop();
    _inputHandlers.clear();
    _logicHandlers.clear();
    _visualHandlers.clear();
  }
}

final gameLoopService = Provider((ref) {
  final service = GameLoopService.instance;
  ref.onDispose(service.dispose);

  return service;
});
