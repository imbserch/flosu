import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flosu/logic/providers/gameplay_controller.dart';
import 'package:flosu/logic/services/gameloop.dart';
import 'package:flosu/models/gameplay/score_state.dart';
import 'package:flosu/ui/widgets/gameplay/replay_mouse_cursor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Slider, PointerEvent;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' hide PointerEvent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flosu/logic/providers/audio.dart';
import 'package:flosu/logic/providers/input.dart';
import 'package:flosu/logic/providers/storage.dart';
import 'package:flosu/models/beatmap/beatmap.dart';
import 'package:flosu/models/beatmap/hit_objects.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/core/extensions.dart';
import 'package:flosu/models/inputs/inputs.dart';
import 'package:flosu/ui/pages/song_select/mods.dart';
import 'package:flosu/logic/gameplay_service.dart';
import 'package:flosu/logic/providers/router.dart';
import 'package:flosu/providers/sample_service.dart';
import 'package:flosu/ui/painters/gameplay.dart';
import 'package:flosu/ui/painters/playfield.dart';
import 'package:flosu/ui/shared/animatable_page.dart';
import 'package:flosu/ui/widgets/common/skewed_box.dart';

/// The main gameplay screen shown while a [Beatmap] is being played.
///
/// This page is responsible for:
/// - Starting the [GameplayController] for the current beatmap.
/// - Forwarding input events from [InputProvider] to [GameplayController].
/// - Displaying the HUD (score, accuracy, combo, health bar, hit error meter).
/// - Transitioning to the results screen when the track ends or health runs out.
/// - Pausing / resuming on Escape.
class GameplayPage extends AnimatablePage {
  const GameplayPage({super.key, required super.uri});

  @override
  AnimatablePageState<GameplayPage> createState() => _GameplayPageState();
}

class _GameplayPageState extends AnimatablePageState<GameplayPage> {
  /// Tracks the set of logical keys held in the previous input event.
  /// Used to detect key-down transitions without repeats.
  Set<LogicalKeyboardKey> _lastKeys = {};

  /// When true, the replay loaded in [GameplayService] is preserved after
  /// leaving this page. Set before navigating to the scoring screen.
  bool _reuseReplay = false;

  /// The background sample event currently playing, if any.
  BeatmapSample? _sample;

  @override
  void initState() {
    final beatmap = ref.read(gameplayService).beatmap!;
    final mods = ref.read(gameplayService).mods;

    // Initialise the controller for this beatmap/mod combination.
    ref
        .read(gameplayControllerProvider.notifier)
        .init(beatmap.difficulty, mods);

    // Set first-frame process
    _process();

    ref.read(gameLoopService).subscribe(TickerPhase.logic, _process);
    ref.read(inputProvider.notifier).addInmediateHandler(_onInput);

    super.initState();
  }

  @override
  void dispose() {
    _lastKeys.clear();

    // Widget is unsafe; access providers via globalRef after disposal.
    final beatmap = globalRef.read(gameplayService).beatmap!;

    globalRef.read(gameLoopService).unsubscribe(TickerPhase.logic, _process);
    globalRef.read(inputProvider.notifier).removeInmediateHandler(_onInput);

    Future.microtask(() {
      globalRef.read(audioProvider.notifier).preview(beatmap, true);
      if (!_reuseReplay) {
        globalRef.read(gameplayService.notifier).clearReplay();
      }
    });

    super.dispose();
  }

  // The input handling will be managed by controller
  void _onInput(Set<LogicalKeyboardKey> keys, PointerEvent? pointer) {
    // Pointer-only events can arrive with the same key set — skip them.
    if (setEquals(_lastKeys, keys)) return;

    if (keys.changedAndPressed(LogicalKeyboardKey.escape, _lastKeys)) {
      _pauseResume();
    }

    _lastKeys = keys.toSet();
  }

  // The processing will be managed by controller
  void _process([_]) {
    final audio = ref.read(audioProvider.notifier);
    final controller = ref.read(gameplayControllerProvider.notifier);
    final beatmap = ref.read(gameplayService).beatmap!;

    if (audio.playing) {
      final score = controller.stateNotifier.value;

      // Navigate to results when audio ends or health reaches zero.
      if ((audio.completed || !score.isAlive) && mounted) {
        _reuseReplay = true;
        context.go("/scoring");
        return;
      }

      // Switch background sample when needed.
      final sample = beatmap.events.whereType<BeatmapSample>().lastWhereOrNull(
        (bs) => audio.positionInMs > bs.time,
      );

      if (_sample?.file != sample?.file) {
        if (sample != null) ref.read(sampleService).play(sample.file);
        _sample = sample;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Navigation helpers
  // ---------------------------------------------------------------------------

  /// Restarts the map from the beginning.
  void _reset() {
    _reuseReplay = true;
    if (mounted) context.go("/load");
  }

  /// Toggles the pause state of the audio and, if relevant, the background
  /// sample currently playing.
  void _pauseResume() {
    final audio = ref.read(audioProvider.notifier);
    final sampleManager = ref.read(sampleService);

    if (audio.playing) {
      if (_sample != null) sampleManager.pause(_sample!.file);
      audio.setPlaying(false);
    } else {
      if (_sample != null) sampleManager.resume(_sample!.file);
      audio.setPlaying(true);
    }

    if (mounted) setState(() {});
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget buildPage(BuildContext context, double animProgress) {
    final audio = ref.read(audioProvider.notifier);
    final details = ref.watch(gameplayService);

    return Stack(
      fit: .expand,
      children: [
        // ------ Mod icons -------------------------------------------------------
        Align(
          alignment: .topRight,
          child: Padding(
            padding: const .symmetric(vertical: 16, horizontal: 20),
            child: Row(
              mainAxisAlignment: .end,
              mainAxisSize: .min,
              children: [
                for (final mod in details.mods)
                  ModIcon.display(mod: mod, size: 24),
              ],
            ),
          ),
        ),

        // ------ Playfield -------------------------------------------------------
        Center(
          child: AspectRatio(
            aspectRatio: 512 / 388,
            child: FittedBox(
              fit: .contain,
              child: Container(
                margin: const .fromLTRB(0, 8, 0, 0),
                child: Container(
                  margin: .all(1.5 * details.beatmap!.difficulty.circleRadius),
                  height: 384,
                  width: 512,
                  child: Stack(
                    fit: .expand,
                    alignment: .center,
                    clipBehavior: .none,
                    children: [
                      PlayfieldHitObjects(
                        onObjectsUpdated: (objects, positionInMs) {},
                        onInput: (keys, pointer, objects, positionInMs) {},
                      ),

                      // Use replay mouse cursor when watching a replay.
                      if (details.replay != null) const ReplayMouseCursor(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // ------ Pause overlay --------------------------------------------------
        TweenAnimationBuilder(
          tween: Tween(end: audio.playing ? 0.0 : 1.0),
          duration: Durations.medium1,
          curve: Curves.easeOut,
          builder: (_, t, child) => t == 0
              ? const SizedBox.shrink()
              : Opacity(
                  opacity: t,
                  child: ColoredBox(
                    color: Colors.black.withAlpha(64),
                    child: Align(
                      alignment: .bottomCenter,
                      child: Padding(
                        padding: const .all(16),
                        child: Column(
                          mainAxisSize: .min,
                          crossAxisAlignment: .center,
                          spacing: 8,
                          children: [
                            const Text(
                              "Gameplay paused",
                              style: TextStyle(fontSize: 8),
                            ),
                            Row(
                              spacing: 8,
                              mainAxisSize: .min,
                              children: [
                                SkewedBox(
                                  width: 80,
                                  offset: Offset(0, 16 * (1 - t)),
                                  onTap: _pauseResume,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                  ),
                                  padding: const .all(8),
                                  child: const Text(
                                    "Resume",
                                    textAlign: .center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: .bold,
                                    ),
                                  ),
                                ),
                                SkewedBox(
                                  width: 80,
                                  offset: Offset(0, -16 * (1 - t)),
                                  onTap: _reset,
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade700,
                                  ),
                                  padding: const .all(8),
                                  child: const Text(
                                    "Retry",
                                    textAlign: .center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: .bold,
                                    ),
                                  ),
                                ),
                                SkewedBox(
                                  width: 80,
                                  offset: Offset(0, 16 * (1 - t)),
                                  onTap: () => context.go("/songs"),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                  ),
                                  padding: const .all(8),
                                  child: const Text(
                                    "Go back",
                                    textAlign: .center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: .bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

// =============================================================================
// PlayfieldHitObjects
// =============================================================================

/// Callback invoked on every tick with the current playfield state.
typedef OnObjectsUpdated =
    void Function(List<HitObject> objects, int positionInMs);

/// Callback invoked when a key-down event should be evaluated for hit detection.
typedef OnInput =
    void Function(
      Set<LogicalKeyboardKey> keys,
      PointerEvent? pointer,
      List<HitObject> activeObjects,
      int positionInMs,
    );

/// A self-contained widget that drives the [PlayfieldPainter] using a [Ticker].
///
/// On every frame it:
/// 1. Reads the current audio position from [AudioProvider].
/// 2. Filters the beatmap's hit objects to those visible at that position.
/// 3. Pushes updated values to [ValueNotifier]s consumed by [PlayfieldPainter].
/// 4. Invokes [onObjectsUpdated] so the parent can run miss detection.
///
/// Input handling is also forwarded here because this widget knows both the
/// active object list and the current position — the two values needed for
/// hit detection.
class PlayfieldHitObjects extends ConsumerStatefulWidget {
  const PlayfieldHitObjects({
    super.key,
    required this.onObjectsUpdated,
    required this.onInput,
  });

  /// Called on every tick with the currently visible objects and position.
  final OnObjectsUpdated onObjectsUpdated;

  /// Called when a key-down event should be evaluated for hit detection.
  final OnInput onInput;

  @override
  ConsumerState<PlayfieldHitObjects> createState() =>
      _PlayfieldHitObjectsState();
}

class _PlayfieldHitObjectsState extends ConsumerState<PlayfieldHitObjects> {
  /// Notifier for the current audio position in milliseconds.
  final ValueNotifier<int> _posNotifier = ValueNotifier(0);

  /// Notifier for the list of currently visible hit objects.
  final ValueNotifier<List<HitObject>> _objectsNotifier = ValueNotifier([]);

  late final Beatmap _beatmap;

  // Tracks last keys to detect transitions inside this widget.
  Set<LogicalKeyboardKey> _lastKeys = {};

  @override
  void initState() {
    _beatmap = ref.read(audioProvider)!;

    ref.read(gameLoopService).subscribe(TickerPhase.logic, _calculateObjects);

    // Register for immediate input events to handle hit detection.
    ref.read(inputProvider.notifier).addInmediateHandler(_onInput);

    super.initState();
  }

  @override
  void dispose() {
    _objectsNotifier.dispose();
    _posNotifier.dispose();

    globalRef
        .read(gameLoopService)
        .unsubscribe(TickerPhase.logic, _calculateObjects);

    Future.microtask(
      () => globalRef
          .read(inputProvider.notifier)
          .removeInmediateHandler(_onInput),
    );

    super.dispose();
  }

  /// Handles raw input from [InputProvider] and forwards qualifying events
  /// to the parent via [PlayfieldHitObjects.onInput].
  void _onInput(Set<LogicalKeyboardKey> keys, PointerEvent? pointer) {
    if (setEquals(_lastKeys, keys)) {
      _lastKeys = Set.of(keys);
      return;
    }
    _lastKeys = Set.of(keys);

    widget.onInput(keys, pointer, _objectsNotifier.value, _posNotifier.value);
  }

  /// Computes which hit objects are visible at the current audio position
  /// and updates both [ValueNotifier]s.
  void _calculateObjects(_) {
    final positionInMs = ref.read(audioProvider.notifier).positionInMs;
    if (positionInMs != _posNotifier.value) {
      _posNotifier.value = positionInMs;
    }

    final diff = _beatmap.difficulty;

    final objectsInTime = _beatmap.objects
        .where((o) => o.canShow(positionInMs, diff))
        .toList();

    if (!listEquals(_objectsNotifier.value, objectsInTime)) {
      _objectsNotifier.value = objectsInTime.reversed.toList();
    }

    // Notify parent so it can run miss detection.
    widget.onObjectsUpdated(objectsInTime, positionInMs);
  }

  @override
  Widget build(BuildContext context) {
    final snakingSliders = ref.watch(
      storageProvider.select((it) => it.snakingSliders),
    );
    final mods = ref.read(gameplayService.select((it) => it.mods));

    return RepaintBoundary(
      child: CustomPaint(
        painter: PlayfieldPainter(
          position: _posNotifier,
          objects: _objectsNotifier,
          difficulty: _beatmap.difficulty,
          snakingSliders: snakingSliders,
          mods: mods,
        ),
      ),
    );
  }
}
