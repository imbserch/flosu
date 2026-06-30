import 'package:flosu/core/enums.dart';
import 'package:flosu/logic/providers/gameplay_controller.dart';
import 'package:flosu/logic/services/game_loop.dart';
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
import 'package:flosu/core/extensions/models.dart';
import 'package:flosu/models/inputs/inputs.dart';
import 'package:flosu/ui/pages/song_select/mods.dart';
import 'package:flosu/logic/providers/gameplay_service.dart';
import 'package:flosu/logic/providers/router.dart';
import 'package:flosu/logic/services/sample.dart';
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
  void _process([_]) {}

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

  @override
  Widget buildPage(BuildContext context, double animProgress) {
    final controller = ref.watch(gameplayControllerProvider);
    final audio = ref.read(audioProvider.notifier);
    final details = ref.watch(gameplayService);

    return Stack(
      fit: .expand,
      children: [
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

/// Callback invoked on every tick with the current playfield state.
typedef OnObjectsUpdated =
    void Function(List<HitObject> objects, int positionInMs);

/// A self-contained widget that drives the [PlayfieldPainter] using a [Ticker].
///
/// On every frame it:
/// 1. Reads the current audio position from [AudioProvider].
/// 2. Filters the beatmap's hit objects to those visible at that position.
/// 3. Pushes updated values to [ValueNotifier]s consumed by [PlayfieldPainter].
/// 4. Invokes [onObjectsUpdated] so the parent can run miss detection.
class PlayfieldHitObjects extends ConsumerStatefulWidget {
  const PlayfieldHitObjects({super.key, required this.onObjectsUpdated});

  /// Called on every tick with the currently visible objects and position.
  final OnObjectsUpdated onObjectsUpdated;

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
  late final double _maxObjectDuration;

  @override
  void initState() {
    _beatmap = ref.read(audioProvider)!;

    // Precompute the maximum duration among all hit objects.
    double maxDur = 0.0;
    for (final obj in _beatmap.objects) {
      final double dur = switch (obj) {
        HitCircle() => 0.0,
        Slider() => obj.duration,
        Spinner() => obj.duration.toDouble(),
      };
      if (dur > maxDur) {
        maxDur = dur;
      }
    }
    _maxObjectDuration = maxDur;

    ref.read(gameLoopService).subscribe(TickerPhase.logic, _calculateObjects);

    super.initState();
  }

  @override
  void dispose() {
    _objectsNotifier.dispose();
    _posNotifier.dispose();

    globalRef
        .read(gameLoopService)
        .unsubscribe(TickerPhase.logic, _calculateObjects);

    super.dispose();
  }

  /// Binary searches the first index where `hitTime` >= `targetTime`.
  int _binarySearchFirstIndex(List<HitObject> objects, double targetTime) {
    int low = 0;
    int high = objects.length;
    while (low < high) {
      final mid = (low + high) >> 1;
      if (objects[mid].hitTime >= targetTime) {
        high = mid;
      } else {
        low = mid + 1;
      }
    }
    return low;
  }

  /// Computes which hit objects are visible at the current audio position
  /// and updates both [ValueNotifier]s.
  void _calculateObjects(_) {
    final positionInMs = ref.read(audioProvider.notifier).positionInMs;
    if (positionInMs != _posNotifier.value) {
      _posNotifier.value = positionInMs;
    }

    final diff = _beatmap.difficulty;
    final objects = _beatmap.objects;

    // Use binary search to locate the window of potentially visible objects.
    final minHitTime = positionInMs - _maxObjectDuration - diff.hit50;
    final maxHitTime = positionInMs + diff.preempt;

    final startIndex = _binarySearchFirstIndex(objects, minHitTime);
    final endIndex = _binarySearchFirstIndex(objects, maxHitTime + 1);

    final objectsInTime = <HitObject>[];
    for (int i = startIndex; i < endIndex; i++) {
      final o = objects[i];
      if (o.canShow(positionInMs, diff)) {
        objectsInTime.add(o);
      }
    }

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
