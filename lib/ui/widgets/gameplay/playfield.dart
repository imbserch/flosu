import 'package:collection/collection.dart';
import 'package:flosu/logic/providers/audio.dart';
import 'package:flosu/logic/providers/gameplay_data.dart';
import 'package:flosu/shared/navigation/router.dart';
import 'package:flosu/logic/providers/settings.dart';
import 'package:flosu/logic/services/game_loop.dart';
import 'package:flosu/models/beatmap/hit_objects.dart';
import 'package:flosu/models/gameplay/gameplay_info.dart';
import 'package:flosu/ui/painters/gameplay/base.dart';
import 'package:flosu/ui/painters/gameplay/hit_objects/hit_circle.dart';
import 'package:flosu/ui/painters/gameplay/hit_objects/slider.dart';
import 'package:flosu/ui/painters/gameplay/hit_objects/spinner.dart';
import 'package:flosu/ui/painters/gameplay/playfield.dart';
import 'package:flutter/material.dart' hide Slider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Playfield extends ConsumerStatefulWidget {
  const Playfield({super.key});

  @override
  ConsumerState<Playfield> createState() => _PlayfieldState();
}

class _PlayfieldState extends ConsumerState<Playfield> {
  late final GameplayInfo _details = ref.read(gameplayDataProvider);

  late final List<int> _objectHitTimes = _details.contents!.objects
      .map((o) => o.hitTime)
      .toList();

  final _position = ValueNotifier<int>(0);
  late final _objects = ValueNotifier<List<PlayfieldDrawable>>([]);

  // Internal flag for allowing properly slider snake
  bool _canSnake = false;

  @override
  void initState() {
    ref.listenManual(
      settingsProvider.select((it) => it.snakingSlidersEnabled),
      _updateSliderSnake,
      fireImmediately: true,
    );
    ref.read(gameLoopService).subscribe(.logic, _updatePlayfield);
    super.initState();
  }

  @override
  void dispose() {
    globalRef.read(gameLoopService).unsubscribe(.logic, _updatePlayfield);
    super.dispose();
  }

  void _updatePlayfield(_) {
    final position = ref.read(audioProvider.notifier).positionInMs;

    final preempt = _details.difficultyWithMods.preempt;
    final mods = _details.mods;

    final currentIndex = _objectHitTimes.lowerBound(
      position,
      (a, b) => a.compareTo(b),
    );

    final currentDrawables = _objects.value;
    final newDrawables = <PlayfieldDrawable>[];
    final aliveDrawables = <PlayfieldDrawable>[];

    for (int i = currentIndex; i < _objectHitTimes.length; i++) {
      final hitTime = _objectHitTimes[i];
      final object = _details.contents!.objects[i];

      if (position >= hitTime - preempt) {
        final alreadyExists = currentDrawables.any(
          (d) => d is HitObjectDrawable && d.hitObject == object,
        );

        if (!alreadyExists) {
          // All objects use same difficulty with mods applied
          final drawable = switch (object) {
            HitCircle() => HitCircleDrawable(
              hitObject: object,
              difficulty: _details.difficultyWithMods,
              mods: mods,
            ),
            // Set last stored snake state
            Slider() => SliderDrawable(
              hitObject: object,
              difficulty: _details.difficultyWithMods,
              mods: mods,
            )..enableSnake = _canSnake,
            Spinner() => SpinnerDrawable(
              hitObject: object,
              difficulty: _details.difficultyWithMods,
              mods: mods,
            ),
          };
          newDrawables.add(drawable);
        }
        continue;
      }
      // Skip
      break;
    }

    for (final drawable in currentDrawables) {
      if (!drawable.isExpired(position)) aliveDrawables.add(drawable);
    }

    _position.value = position;
    _objects.value = [...newDrawables.reversed, ...aliveDrawables];

    //
  }

  void _updateSliderSnake(_, bool snake) {
    _objects.value.whereType<SliderDrawable>().forEach(
      (it) => it.enableSnake = snake,
    );
    _canSnake = snake;
  }

  @override
  Widget build(BuildContext context) {
    /* final snakingSliders = ref.watch(
      settingsProvider.select((it) => it.snakingSliders),
    );
    final mods = ref.read(gameplayDataProvider.select((it) => it.mods)); */

    return RepaintBoundary(
      child: CustomPaint(
        painter: PlayfieldPainter(position: _position, drawables: _objects),
      ),
    );
  }
}
