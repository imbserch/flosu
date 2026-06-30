import 'package:flosu/models/beatmap/beatmap.dart';

/// A collection of [Beatmap]s that share the same song title and artist.
///
/// In osu! terminology this is analogous to a "beatmap set" — multiple
/// difficulty levels for the same song, shown as a single card in the list.
class BeatmapSet {
  BeatmapSet(this.beatmaps)
    : title = beatmaps.first.info.title,
      artist = beatmaps.first.info.artist;

  /// Shared song title for all beatmaps in this group.
  final String title;

  /// Shared artist name for all beatmaps in this group.
  final String artist;

  /// All parsed difficulty variants for this song, in insertion order.
  final List<Beatmap> beatmaps;
}
