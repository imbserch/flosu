part of "beatmap.dart";

/// Base class for all events found in the `[Events]` section of a `.osu` file.
///
/// Subclasses include [BeatmapBackground], [BeatmapBreak], and [BeatmapSample].
sealed class BeatmapEvent {
  /// Attempts to parse a single row from the `[Events]` section.
  ///
  /// Returns `null` for event types that are not yet supported or recognised.
  ///
  /// [row]    — the comma-split fields of a single event line.
  /// [parent] — absolute path to the beatmap's parent directory, used to
  ///            resolve relative asset paths.
  static BeatmapEvent? fromList(List<String> row, String parent) {
    // Type 0, layer 0 = background image.
    if (row[0] == "0" && row[1] == "0") {
      return BeatmapBackground(File("$parent/${row[2].replaceAll("\"", "")}"));
    }

    // Type 2 or "Break" = rest period.
    if (row[0] == "Break" || row[0] == "2") {
      return BeatmapBreak(int.parse(row[1]), int.parse(row[2]));
    }

    // "Sample" with layer 0 = background audio sample.
    if (row[0] == "Sample" && row[2] == "0") {
      return BeatmapSample(
        int.parse(row[1]),
        "$parent/${row[3].replaceAll("\"", "")}",
        double.parse(row[4]) / 100,
      );
    }

    return null;
  }
}

/// A background image displayed behind the playfield.
class BeatmapBackground extends BeatmapEvent {
  BeatmapBackground(this.file);

  /// Absolute path to the background image file.
  final File file;
}

/// A rest period during which no hit objects appear and health does not drain.
class BeatmapBreak extends BeatmapEvent {
  BeatmapBreak(this.startTime, this.endTime);

  /// Timestamp (in ms) when the break begins.
  final int startTime;

  /// Timestamp (in ms) when the break ends.
  final int endTime;
}

/// A background audio sample that plays at a specific point in the track.
class BeatmapSample extends BeatmapEvent {
  BeatmapSample(this.time, this.file, this.volume);

  /// Timestamp (in ms) when the sample should start playing.
  final int time;

  /// Absolute path to the audio sample file.
  final String file;

  /// Playback volume, normalised to [0.0, 1.0].
  final double volume;
}
