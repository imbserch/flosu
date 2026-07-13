import 'dart:ui';

import 'package:flosu/models/beatmap/hit_objects.dart';
import 'package:flosu/models/beatmap/timing_points.dart';

class BeatmapContent {
  const BeatmapContent({
    this.md5,
    required this.objects,
    required this.timingPoints,
    required this.colors,
  });

  final String? md5;

  final List<HitObject> objects;
  final List<TimingPoint> timingPoints;
  final List<Color> colors;
}
