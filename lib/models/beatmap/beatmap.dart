// Wrapper class for the complete state of a parsed beatmap.
// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:flutter/material.dart' hide Slider;
import 'package:flosu/models/beatmap/hit_objects.dart';

part "metadata.dart";
part "events.dart";
part "timing_points.dart";

/// Represents a fully parsed osu! standard beatmap.
///
/// A [Beatmap] is immutable after construction. It is produced by
/// [BeatmapParser] and stored in the library via [LibraryProvider].
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

  /// MD5 hash of the `.osu` file, used to match replay files to their map.
  final String hash;

  /// Identifier shared by all difficulties of the same song set.
  final int groupId;

  /// General metadata (title, artist, creator, etc.).
  final BeatmapInfo info;

  /// Audio file path and preview timing.
  final BeatmapAudio audio;

  /// Difficulty settings (CS, HP, OD, AR, etc.).
  final BeatmapDifficulty difficulty;

  /// Ordered list of timing points (both uninherited and inherited).
  final List<TimingPoint> timing;

  /// The combo color palette defined in the `.osu` file.
  final List<Color> colors;

  /// Background, break, and sample events parsed from the `[Events]` section.
  final List<BeatmapEvent> events;

  /// All playable hit objects, in chronological order.
  final List<HitObject> objects;

  /// The background image event, if one is defined in the map.
  BeatmapBackground? get background =>
      events.whereType<BeatmapBackground>().firstOrNull;

  /// The total drain time of the beatmap (excluding break sections).
  ///
  /// Calculated as the duration from the first to the last object,
  /// minus the total length of all [BeatmapBreak] events.
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

  /// Whether a beatmap belongs to the same song set.
  bool isFromSameBeatmapSet(Beatmap beatmap) =>
      beatmap.groupId == groupId &&
      beatmap.info.title == info.title &&
      beatmap.info.artist == info.artist;
}
