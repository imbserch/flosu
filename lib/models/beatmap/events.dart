part of "beatmap.dart";

sealed class BeatmapEvent {
  static BeatmapEvent? fromList(List<String> row, String parent) {
    if (row[0] == "0" && row[1] == "0") {
      return BeatmapBackground(File("$parent/${row[2].replaceAll("\"", "")}"));
    }

    if (row[0] == "Break" || row[0] == "2") {
      return BeatmapBreak(int.parse(row[1]), int.parse(row[2]));
    }

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

class BeatmapBackground extends BeatmapEvent {
  BeatmapBackground(this.file);
  final File file;
}

class BeatmapBreak extends BeatmapEvent {
  BeatmapBreak(this.startTime, this.endTime);
  final int startTime;
  final int endTime;
}

class BeatmapSample extends BeatmapEvent {
  BeatmapSample(this.time, this.file, this.volume);
  final int time;
  final String file;
  final double volume;
}
