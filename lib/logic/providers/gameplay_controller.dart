import 'package:flosu/logic/providers/input.dart';
import 'package:flutter/material.dart' hide Slider, PointerEvent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flosu/models/beatmap/beatmap.dart';
import 'package:flosu/models/beatmap/hit_objects.dart';
import 'package:flosu/models/gameplay/score_state.dart';
import 'package:flosu/models/inputs/inputs.dart';
import 'package:flosu/models/mods/base.dart';

/// TODO: Reimplement GameplayController to use a more modern approach,
/// possibly using a game loop or ticker system.
///
/// The current implementation is very basic and doesn't
/// handle many edge cases.
///
/// This must implement internally the input service and cast input into playfield coords,
/// while processing input events through the current beatmap.
///
/// Should implement hit detection, scoring, health, accuracy, combo, etc.
///
/// TODO: Modify notifier type to use state
class GameplayController extends Notifier<void> {
  // Initialize state and dispose event listeners for all services used in gameplay
  @override
  void build() {
    ref.read(inputProvider.notifier).addDelayedHandler(_input);

    ref.onDispose(() {
      ref.read(inputProvider.notifier).removeDelayedHandler(_input);
    });
  }

  // ---------------------------------------------------------------------------
  // Internal state
  // ---------------------------------------------------------------------------

  /// Current snapshot of all scoring metrics.
  ScoreState _state = const ScoreState();

  /// Set of objects that have already been judged (hit or missed).
  /// Prevents double-evaluation of the same object.
  final Set<HitObject> _judgedObjects = {};

  late final ValueNotifier<ScoreState> stateNotifier = ValueNotifier(_state);

  /// Initialises the controller for a new play session.
  ///
  /// Must be called once before [processInput] or [processTick].
  void init(BeatmapDifficulty difficulty, Set<ConfigurableMod> mods) {
    _state = const ScoreState();
    _judgedObjects.clear();
    stateNotifier.value = _state;
  }

  /// Resets all live state to its initial values.
  ///
  /// Call this when the player retries the map without restarting the provider.
  void reset() {
    _state = const ScoreState();
    _judgedObjects.clear();
    stateNotifier.value = _state;
  }

  void _input(InputEvents lastTickEvents) {}

  /// Checks for objects that have expired without being hit and marks them
  /// as misses.
  ///
  /// Must be called once per frame from the gameplay ticker.
  ///
  /// [positionInMs]  — the current audio position, in milliseconds.
  /// [activeObjects] — the objects currently visible on the playfield.
  void processTick(int positionInMs, List<HitObject> activeObjects) {}
}

/// Global provider for the [GameplayController] singleton.
///
/// Use `ref.read(gameplayControllerProvider.notifier)` to access methods,
/// and `ref.read(gameplayControllerProvider.notifier).stateNotifier` to
/// subscribe to live score updates.
final gameplayControllerProvider = NotifierProvider<GameplayController, void>(
  () => GameplayController(),
);
