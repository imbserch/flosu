import 'dart:math';

import 'package:collection/collection.dart';
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
import 'package:flosu/models/gameplay/hit_data.dart';
//import 'package:flosu/models/gameplay/input_events.dart';
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

class GameplayPage extends AnimatablePage {
  const GameplayPage({super.key, required super.uri});

  @override
  AnimatablePageState<GameplayPage> createState() => _GameplayPageState();
}

class _GameplayPageState extends AnimatablePageState<GameplayPage> {
  //History key events
  Set<LogicalKeyboardKey> _lastKeys = {};

  //This is meant for prevent losing replay data while re-loading or going to scoring page
  bool _reuseReplay = false;

  final int _combo = 0;
  final double _score = 0;
  final double _health = 200;

  BeatmapSample? _sample;

  late final Ticker _timeTicker;
  //final List<PointerEventWithTimestamp> _replayEvents = [];
  final List<HitData> _hits = [];

  double get _accuracy {
    final sum = _hits.map((h) => h.result.value).sum;

    return sum / (300 * _hits.length);
  }

  double get _avgHitTime {
    final notMisses = _hits.where((h) => h.result != .miss);
    return notMisses.isEmpty
        ? 0
        : -notMisses.map((h) => h.timeLeft).sum / notMisses.length;
  }

  @override
  void initState() {
    _process(null);
    _timeTicker = Ticker(_process)..start();
    ref.read(inputProvider.notifier).addInmediateHandler(_onInput);

    super.initState();
  }

  @override
  dispose() {
    _lastKeys.clear();
    _timeTicker.stop();

    //Widget is unsafe, calling from root navigator
    final beatmap = globalRef.read(gameplayService).beatmap!;

    globalRef.read(inputProvider.notifier).removeInmediateHandler(_onInput);

    Future.microtask(() {
      globalRef.read(audioProvider.notifier).preview(beatmap, true);
      if (!_reuseReplay) {
        globalRef.read(gameplayService.notifier).clearReplay();
      }
    });

    super.dispose();
  }

  void _onInput(Set<LogicalKeyboardKey> keys, PointerEvent? pointer) {
    //Pointer events returning same keys, breaking...
    if (setEquals(_lastKeys, keys)) return;

    _process(null);

    //Ensure the "Escape" key is pressed
    if (keys.changedAndPressed("Escape", _lastKeys)) _pauseResume();

    _lastKeys = keys.toSet();
  }

  void _process(_) {
    final audio = ref.read(audioProvider.notifier);
    //Process events from replay (if any)
    _processReplay(audio.position);

    final beatmap = ref.read(gameplayService).beatmap!;

    if (audio.playing) {
      //Exit early and go to results if audio has finished
      if ((audio.completed || _health <= 0) && mounted) {
        _reuseReplay = true;
        context.go("/scoring");
        return;
      }

      //Find and play samples
      final sample = beatmap.events.whereType<BeatmapSample>().lastWhereOrNull(
        (bs) => audio.positionInMs > bs.time,
      );

      //If sample has changed, play new sample
      if (_sample?.file != sample?.file) {
        if (sample != null) ref.read(sampleService).play(sample.file);
        _sample = sample;
      }
    }
  }

  void _processReplay(Duration position) {
    /* final replay = ref.read(gameplayService).replay;
    final audio = ref.read(audioProvider.notifier);

    if (replay != null) {
      final frame = audio.positionInMs.isNegative
          ? replay.frames.lastWhereOrNull((fr) => fr.time < audio.positionInMs)
          : replay.frames.firstWhereOrNull(
              (fr) => fr.time > audio.positionInMs,
            );

      if (frame != null) {
        //Simulate event of movement
        final event = PointerEventWithTimestamp.fromFrame(frame);

        _replayEvents.add(event);
        if (_replayEvents.length > 50) _replayEvents.removeAt(0);
      }
    } */
  }

  void _reset() {
    _reuseReplay = true;
    if (mounted) context.go("/load");
  }

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
    final audio = ref.read(audioProvider.notifier);
    final details = ref.watch(gameplayService);

    return Stack(
      fit: .expand,
      children: [
        Align(
          alignment: .topLeft,
          child: SkewedBox(
            width: 180,
            skew: .4,
            offset: const Offset(-16, 16),
            useGradientBorder: true,
            decoration: BoxDecoration(
              borderRadius: .circular(6),
              color: AppColors.background.withAlpha(192),
            ),
            child: Column(
              crossAxisAlignment: .stretch,
              mainAxisSize: .min,
              children: [
                SkewedBox(
                  skew: .4,
                  offset: const Offset(4, 0),
                  padding: const .symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: .circular(6),
                    color: AppColors.container,
                  ),
                  child: Text(
                    _score < 1000000
                        ? "${(_score + 1000000).round()}".substring(1)
                        : "${_score.round()}",
                    style: const TextStyle(
                      fontWeight: .bold,
                      fontSize: 18,
                      height: 1,
                    ),
                    textAlign: .end,
                  ),
                ),
                Padding(
                  padding: const .symmetric(vertical: 4, horizontal: 16),
                  child: Text(
                    "${(_accuracy.isNaN ? 100 : _accuracy).toStringAsFixed(2)}%",
                    style: const TextStyle(fontSize: 10, fontWeight: .bold),
                    textAlign: .end,
                  ),
                ),
              ],
            ),
          ),
        ),
        ListenableBuilder(
          listenable: ValueNotifier(_health),
          builder: (_, child) => TweenAnimationBuilder(
            tween: Tween(end: _health / 200),
            duration: Durations.medium1,
            curve: Curves.easeOut,
            builder: (_, t, child) =>
                CustomPaint(painter: LifeBarPainter(t), child: child),
            child: child,
          ),
        ),
        Align(
          alignment: .topLeft,
          child: SkewedBox(
            skew: .4,
            offset: const Offset(-16, 72),
            padding: const .fromLTRB(64, 4, 16, 4),
            useGradientBorder: true,
            decoration: BoxDecoration(
              color: AppColors.containerHigh.withAlpha(192),
            ),
            child: Text(
              "${_combo}x",
              style: const TextStyle(fontSize: 10, fontWeight: .bold),
            ),
          ),
        ),

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

        //Score
        /* Align(
          alignment: .topLeft,
          child: SkewedBox(
            height: 56,
            width: 190,
            offset: const Offset(-12, 0),
            skew: 3 / 5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.withAlpha(64), Colors.transparent],
                stops: [0, 1],
                begin: .bottomCenter,
                end: .topCenter,
              ),
              borderRadius: const .only(bottomRight: .circular(8)),
            ),
          ),
        ),
        Align(
          alignment: .topLeft,
          child: SkewedBox(
            height: 60,
            width: 194,
            offset: const Offset(-12, 0),
            skew: 3 / 5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.withAlpha(128), Colors.transparent],
                stops: [0, 1],
                begin: .bottomCenter,
                end: .topCenter,
              ),
              borderRadius: const .only(bottomRight: .circular(8)),
            ),
          ),
        ),
        Align(
          alignment: .topLeft,
          child: Container(
            height: 2,
            width: 22,
            margin: const .only(top: 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: .circular(1),
            ),
          ),
        ),
        Align(
          alignment: .topLeft,
          child: Container(
            padding: const .fromLTRB(32, 14, 0, 0),
            child: ListenableBuilder(
              listenable: ValueNotifier(_health),
              builder: (_, child) => TweenAnimationBuilder(
                tween: Tween(end: _health / 200),
                duration: Durations.medium1,
                curve: Curves.easeOut,
                builder: (_, t, child) =>
                    CustomPaint(painter: LifeBarPainter(t), child: child),
                child: child,
              ),
              child: Container(
                padding: const .fromLTRB(2, 14, 0, 0),
                width: 116,
                child: Column(
                  children: [
                    TweenAnimationBuilder(
                      tween: Tween(end: _score),
                      duration: Durations.long2,
                      curve: Curves.easeOut,
                      builder: (_, t, _) => Text(
                        "${t.round()}",
                        textAlign: .end,
                        style: const TextStyle(fontFamily: "Venera", fontSize: 16),
                      ),
                    ),
                    Text(
                      "100.00%",
                      textAlign: .end,
                      style: const TextStyle(
                      
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
 */

        //Pressed Keys
        //TODO: REIMPLEMENT OR REMOVE THIS
        /* Align(
          alignment: .bottomRight,
          child: Container(
            width: 104,
            height: 38,
            padding: const .fromLTRB(0, 0, 16, 16),
            margin: const .only(bottom: 20),
            child: Row(
              spacing: 4,
              mainAxisSize: .min,
              crossAxisAlignment: .stretch,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: .stretch,
                    mainAxisSize: .min,
                    children: [
                      AnimatedContainer(
                        duration: Durations.short2,
                        curve: Curves.easeOut,
                        height: 2,
                        margin: .fromLTRB(
                          0,
                          _k1Pressed ? 2 : 0,
                          0,
                          _k1Pressed ? 0 : 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(_k1Pressed ? 255 : 128),
                          borderRadius: .circular(2),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "K1",
                        style: TextStyle(
                          fontSize: 6,
                          color: Colors.blue.shade200,
                          height: 1,
                        ),
                      ),
                      Text(
                        "$_k1TimesPressed",
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: .bold,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .stretch,
                    mainAxisSize: .min,
                    children: [
                      AnimatedContainer(
                        duration: Durations.short2,
                        curve: Curves.easeOut,
                        height: 2,
                        margin: .fromLTRB(
                          0,
                          _k2Pressed ? 2 : 0,
                          0,
                          _k2Pressed ? 0 : 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(_k2Pressed ? 255 : 128),
                          borderRadius: .circular(2),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "K2",
                        style: TextStyle(
                          fontSize: 6,
                          color: Colors.blue.shade200,
                          height: 1,
                        ),
                      ),
                      Text(
                        "$_k2TimesPressed",
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: .bold,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .stretch,
                    mainAxisSize: .min,
                    children: [
                      AnimatedContainer(
                        duration: Durations.short2,
                        curve: Curves.easeOut,
                        height: 2,
                        margin: const .fromLTRB(0, 0, 0, 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(128),
                          borderRadius: .circular(2),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "SMOKE",
                        style: TextStyle(
                          fontSize: 6,
                          color: Colors.blue.shade200,
                          height: 1,
                        ),
                      ),
                      const Text(
                        "0",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: .bold,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
 */

        //Hit error meter
        Align(
          alignment: .centerLeft,
          child: Container(
            margin: const .only(left: 12),
            height: details.beatmap!.difficulty.hit50,
            width: 1,
            decoration: const BoxDecoration(color: Colors.white30),
            child: Stack(
              clipBehavior: .none,
              children: [
                ..._hits.map(
                  (h) => Positioned(
                    top:
                        (h.timeLeft / 2) -
                        .5 +
                        (details.beatmap!.difficulty.hit50 / 2),
                    left: -3.5,
                    child: TweenAnimationBuilder(
                      key: ValueKey(h),
                      tween: Tween(begin: 1.0, end: 0.0),
                      duration: const Duration(seconds: 2),
                      builder: (_, t, _) => Container(
                        height: 2,
                        width: 8,
                        decoration: BoxDecoration(
                          borderRadius: .circular(1),
                          color: h.result.color.withAlpha((255 * t).round()),
                        ),
                      ),
                    ),
                  ),
                ),

                AnimatedPositioned(
                  top:
                      (-_avgHitTime / 2) -
                      2 +
                      (details.beatmap!.difficulty.hit50 / 2),
                  left: -1.5,
                  duration: Durations.medium1,
                  curve: Curves.easeOut,
                  child: Container(
                    height: 4,
                    width: 4,
                    decoration: BoxDecoration(
                      borderRadius: .circular(2),
                      color: Colors.blue.shade300,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        //Playfield
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
                  child: const Stack(
                    fit: .expand,
                    alignment: .center,
                    clipBehavior: .none,
                    children: [
                      PlayfieldHitObjects(),
                      //TODO: UPDATE - Fake mouse for replays
                      /* if (details.replay != null)
                        Mouse.fromEvents(
                          all: _replayEvents,
                          color: details.beatmap!.colors[0],
                        ), */
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        //Pause
        TweenAnimationBuilder(
          tween: Tween(end: audio.playing ? 0.0 : 1.0),
          duration: Durations.medium1,
          curve: Curves.easeOut,
          builder: (_, t, child) => t == 0
              ? const SizedBox.shrink()
              : Opacity(
                  opacity: t,
                  child: ColoredBox(
                    color: Colors.black.withAlpha(192),
                    child: child,
                  ),
                ),
          child: Center(
            child: Container(
              decoration: BoxDecoration(color: Colors.grey.shade800),
              padding: const .symmetric(horizontal: 64),
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .stretch,
                children: [
                  SkewedBox(
                    skew: 1 / 3,
                    onTap: _pauseResume,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: .zero,
                    ),
                    padding: const .all(12),
                    child: const Text(
                      "Resume",
                      textAlign: .center,
                      style: TextStyle(fontSize: 12, fontWeight: .w600),
                    ),
                  ),
                  SkewedBox(
                    skew: 1 / 3,
                    onTap: _reset,
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      borderRadius: .zero,
                    ),
                    padding: const .all(12),
                    child: const Text(
                      "Retry",
                      textAlign: .center,
                      style: TextStyle(fontSize: 12, fontWeight: .w600),
                    ),
                  ),
                  SkewedBox(
                    skew: 1 / 3,
                    onTap: () => context.go("/songs"),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: .zero,
                    ),
                    padding: const .all(12),
                    child: const Text(
                      "Go Back",
                      textAlign: .center,
                      style: TextStyle(fontSize: 12, fontWeight: .w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PlayfieldHitObjects extends ConsumerStatefulWidget {
  const PlayfieldHitObjects({super.key});

  @override
  ConsumerState<PlayfieldHitObjects> createState() =>
      _PlayfieldHitObjectsState();
}

class _PlayfieldHitObjectsState extends ConsumerState<PlayfieldHitObjects> {
  final ValueNotifier<int> _posNotifier = ValueNotifier(0);
  final ValueNotifier<List<HitObject>> _objectsNotifier = ValueNotifier([]);

  late final Ticker _ticker;
  late final Beatmap _beatmap;

  @override
  initState() {
    _beatmap = ref.read(audioProvider)!;
    _ticker = Ticker(_calculateObjects)..start();
    super.initState();
  }

  @override
  dispose() {
    _objectsNotifier.dispose();
    _posNotifier.dispose();
    _ticker
      ..stop()
      ..dispose();
    super.dispose();
  }

  void _calculateObjects(_) {
    final positionInMs = ref.read(audioProvider.notifier).positionInMs;
    if (positionInMs != _posNotifier.value) _posNotifier.value = positionInMs;

    final diff = _beatmap.difficulty;

    final objectsInTime = _beatmap.objects
        .where((o) => o.canShow(positionInMs, diff))
        .toList();

    if (!listEquals(_objectsNotifier.value, objectsInTime)) {
      _objectsNotifier.value = objectsInTime.reversed.toList();
    }
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
