//Clase para envolver el estado del mapa
// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:flutter/material.dart' hide Slider;
import 'package:flosu/models/beatmap/hit_objects.dart';

part "metadata.dart";
part "events.dart";
part "timing_points.dart";

class Beatmap {
  const Beatmap(
    this.hash,
    this.groupId,
    this.info,
    this.audio,
    this.difficulty,
    this.timing,
    this.colors,
    this.events,
    this.objects,
  );

  final String hash;
  final int groupId;
  final BeatmapInfo info;
  final BeatmapDifficulty difficulty;
  final BeatmapAudio audio;
  final List<TimingPoint> timing;
  final List<Color> colors;
  final List<BeatmapEvent> events;

  final List<HitObject> objects;

  BeatmapBackground? get background =>
      events.whereType<BeatmapBackground>().firstOrNull;

  Duration get drainTime {
    if (objects.length < 2) return Duration.zero;

    final firstHit = objects[0].hitTime;
    final last = objects.last;

    Duration drain = switch (last) {
      HitCircle() => Duration(milliseconds: last.hitTime - firstHit),
      Slider() => Duration(
        milliseconds: (last.hitTime + last.duration - firstHit).round(),
      ),
      Spinner() => Duration(
        milliseconds: (last.hitTime + last.duration - firstHit).round(),
      ),
    };

    final breaks = events.whereType<BeatmapBreak>();

    for (final break_ in breaks) {
      drain -= Duration(milliseconds: break_.endTime - break_.startTime);
    }

    return drain;
  }
}
