import 'package:flosu/core/enums.dart';
//import 'package:flosu/logic/providers/gameplay_service.dart';
//import 'package:flosu/logic/providers/audio.dart';
import 'package:flosu/logic/services/game_loop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' hide PointerEvent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flosu/models/inputs/inputs.dart';

/// TODO: Reimplement GameplayController to use a more modern approach,
/// TODO: Modify notifier type to use state
class GameplayController extends Notifier<void> {
  // Initialize state and dispose event listeners for all services used in gameplay
  @override
  void build() {
    ref.read(gameLoopService).subscribe(TickerPhase.logic, _processTick);

    ref.onDispose(() {
      ref.read(gameLoopService).unsubscribe(TickerPhase.logic, _processTick);
    });
  }

  PointerEvent? _lastValidPointer;
  int _lastValidPointerTimeMs = 0;
  Set<LogicalKeyboardKey> _lastKeys = {};

  bool input(Set<LogicalKeyboardKey> keys, PointerEvent? pointer) {
    // Check if the set of active keyboard keys has changed.
    final keysChanged = !setEquals(_lastKeys, keys);

    if (keysChanged) {
      _lastKeys = Set.of(keys);
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    // Process immediately if keys changed or if there is no previous pointer time.
    if (keysChanged || _lastValidPointer == null) {
      _lastValidPointer = pointer;
      _lastValidPointerTimeMs = now;

      _processInput();
      return false;
    }

    // Otherwise, throttle pointer events to once every 4ms.
    if (now - _lastValidPointerTimeMs >= 4) {
      _lastValidPointer = pointer;
      _lastValidPointerTimeMs = now;

      _processInput();
      return false;
    }

    return false;
  }

  void _processInput() {
    //Process hit detection
  }

  ///
  void _processTick(_) {
    //final position = ref.read(audioProvider.notifier).position;
    //final difficulty = ref.read(gameplayService).difficultyWithMods!;
  }
}

final gameplayControllerProvider = NotifierProvider<GameplayController, void>(
  () => GameplayController(),
);
