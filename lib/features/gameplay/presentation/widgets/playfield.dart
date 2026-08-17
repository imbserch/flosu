import 'package:collection/collection.dart';
import 'package:flosu/core/engine/game_loop.dart';
import 'package:flosu/features/audio/audio.dart';
import 'package:flosu/features/gameplay/presentation/painters/gameplay/base.dart';
import 'package:flosu/features/gameplay/presentation/painters/gameplay/hit_objects/slider.dart';
import 'package:flosu/features/gameplay/presentation/painters/gameplay/playfield.dart';
import 'package:flosu/features/settings/domain/settings_provider.dart';
import 'package:flosu/shared/domain/beatmap/beatmap_selector.dart';
import 'package:flosu/shared/domain/beatmap/hit_object/hit_object.dart';
import 'package:flosu/shared/domain/mod/mod_selector.dart';

import 'package:flutter/material.dart' hide Slider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Playfield extends ConsumerStatefulWidget {
  const Playfield({super.key});

  @override
  ConsumerState<Playfield> createState() => _PlayfieldState();
}

class _PlayfieldState extends ConsumerState<Playfield> with GameLoopListener {
  late final List<HitObject> _hitObjects = ref
      .read(beatmapSelector)!
      .hitObjects;
  late final List<int> _hitObjectTimes = _hitObjects
      .map((o) => o.time)
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
    final beatmap = ref.read(beatmapSelector)!;

    final mods = ref.read(modSelector);
    final position = ref.read(audioClock);
    final difficulty = ref.read(difficultyProvider);

    final preempt = difficulty.preempt;

    final currentIndex = _hitObjectTimes.lowerBound(
      position.round(),
      (a, b) => a.compareTo(b),
    );

    final currentDrawables = _objects.value;
    final newDrawables = <PlayfieldDrawable>[];
    final aliveDrawables = <PlayfieldDrawable>[];

    for (int i = currentIndex; i < _hitObjectTimes.length; i++) {
      final hitTime = _hitObjectTimes[i];
      final object = _hitObjects[i];

      if (position >= hitTime - preempt) {
        final alreadyExists = currentDrawables.any(
          (d) => d is HitObjectDrawable && d.hitObject == object,
        );

        if (!alreadyExists) {
          // All objects use same difficulty with mods applied
          final drawable = HitObjectDrawable.create(
            object,
            beatmap,
            difficulty,
            mods,
            _canSnake,
          );

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
    final mods = ref.read(modSelector);

    return RepaintBoundary(
      child: CustomPaint(
        painter: PlayfieldPainter(
          position: _position,
          drawables: _objects,
          mods: mods,
        ),
      ),
    );
  }
}
