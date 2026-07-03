import 'package:flosu/models/beatmap/beatmap.dart';

/// A collection of [Beatmap]s that share the same song title and artist.
class BeatmapSet {
  /// Creates a new [BeatmapSet] from a single [Beatmap].
  BeatmapSet.fromBeatmap(Beatmap beatmap)
    : id = beatmap.groupId,
      title = beatmap.info.title,
      artist = beatmap.info.artist,
      beatmaps = List.of([beatmap]);

  /// Checks if a [Beatmap] belongs to this [BeatmapSet].
  bool isInBeatmapSet(Beatmap beatmap) =>
      beatmap.groupId == id &&
      beatmap.info.title == title &&
      beatmap.info.artist == artist;

  /// The unique identifier of the beatmap set.
  final int id;

  /// The title of the beatmap set.
  final String title;

  /// The artist of the beatmap set.
  final String artist;

  /// The list of beatmaps in the beatmap set.
  List<Beatmap> beatmaps;
}
