import 'package:collection/collection.dart';
import 'package:flosu/features/audio_experimental/audio.dart';
import 'package:flosu/features/gameplay/domain/gameplay_data.dart';
import 'package:flosu/features/settings/domain/settings.dart';
import 'package:flosu/core/engine/game_loop.dart';
import 'package:flosu/models/beatmap/hit_objects.dart';
import 'package:flosu/features/gameplay/data/gameplay_info.dart';
import 'package:flosu/features/gameplay/presentation/painters/gameplay/base.dart';
import 'package:flosu/features/gameplay/presentation/painters/gameplay/hit_objects/hit_circle.dart';
import 'package:flosu/features/gameplay/presentation/painters/gameplay/hit_objects/slider.dart';
import 'package:flosu/features/gameplay/presentation/painters/gameplay/hit_objects/spinner.dart';
import 'package:flosu/features/gameplay/presentation/painters/gameplay/playfield.dart';
import 'package:flutter/material.dart' hide Slider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Playfield extends ConsumerStatefulWidget {
  const Playfield({super.key});

  @override
  ConsumerState<Playfield> createState() => _PlayfieldState();
}

class _PlayfieldState extends ConsumerState<Playfield> with GameLoopListener {
  late final GameplayInfo _details = ref.read(gameplayDataProvider);

  late final List<int> _objectHitTimes = _details.contents!.objects
      .map((o) => o.hitTime)
      .toList();

  final _position = ValueNotifier<double>(0);
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
    super.initState();
  }

  @override
  void process(double delta) {
    final position = ref.read(audioClockProvider);

    final preempt = _details.difficultyWithMods.preempt;
    final mods = _details.mods;

    final currentIndex = _objectHitTimes.lowerBound(
      position.round(),
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
  }

  void _updateSliderSnake(_, bool snake) {
    _objects.value.whereType<SliderDrawable>().forEach(
      (it) => it.enableSnake = snake,
    );
    _canSnake = snake;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: PlayfieldPainter(position: _position, drawables: _objects),
      ),
    );
  }
}
