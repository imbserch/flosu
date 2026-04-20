// ignore_for_file: non_constant_identifier_names

part of "beatmap.dart";

class BeatmapInfo {
  BeatmapInfo.fromMap(Map<String, dynamic> map)
    : title = map["Title"],
      artist = map["Artist"],
      creator = map["Creator"],
      version = map["Version"],
      source = map["Source"] ?? "",
      tags = map["Tags"] ?? "";

  const BeatmapInfo.empty()
    : title = "",
      artist = "",
      creator = "",
      version = "",
      source = "",
      tags = "";
  final String title;
  final String artist;
  final String creator;
  final String version;
  final String source;
  final String tags;
}

class BeatmapDifficulty {
  BeatmapDifficulty.fromMap(Map<String, dynamic> map)
    : HP = double.parse(map["HPDrainRate"] ?? "5"),
      CS = double.parse(map["CircleSize"] ?? "5"),
      OD = double.parse(map["OverallDifficulty"] ?? "5"),
      AR = double.parse(map["ApproachRate"] ?? "5"),
      sliderMultiplier = double.parse(map["SliderMultiplier"]),
      sliderTickRate = double.parse(map["SliderTickRate"]);

  const BeatmapDifficulty.empty()
    : HP = 0,
      CS = 5,
      OD = 5,
      AR = 5,
      sliderMultiplier = 1,
      sliderTickRate = 1;
  final double HP;
  final double CS;
  final double OD;
  final double AR;
  final double sliderMultiplier;
  final double sliderTickRate;

  //IGNORE: Original replaced by custom
  double get preempt {
    if (AR <= 5) return 1200 + 120 * (5 - AR);
    return 1200 - 150 * (AR - 5);

    /* if (AR <= 5) return 1800 + 180 * (5 - AR);
    return 1800 - 225 * (OD - 5); */
  }

  double get preemptFullOp => preempt / 3;

  double get circleRadius => (54.4 - (4.48 * CS)) * 1.00041;
  double get healthDrain => HP / 100;

  //IGNORE: Original replaced by custom
  double get hit300 => 80 - 6 * OD;
  double get hit100 => 140 - 8 * OD;
  double get hit50 => 200 - 10 * OD;
}

class BeatmapAudio {
  BeatmapAudio.fromMap(Map<String, dynamic> map, String parentPath)
    : path = '$parentPath/${map["AudioFilename"]}',
      previewTime = int.parse(map["PreviewTime"] ?? "0");

  final String path;
  final int previewTime;

  Duration get previewDuration => Duration(milliseconds: previewTime);
}

class BeatmapColors {
  static List<Color> fromList(List<List<dynamic>> list) => list.map((raw) {
    final r = int.tryParse(raw.elementAtOrNull(0) ?? "255") ?? 255;
    final g = int.tryParse(raw.elementAtOrNull(1) ?? "255") ?? 255;
    final b = int.tryParse(raw.elementAtOrNull(2) ?? "255") ?? 255;
    final a = double.tryParse(raw.elementAtOrNull(3) ?? "1.0") ?? 1.0;

    return Color.fromRGBO(r, g, b, a);
  }).toList();

  static const List<Color> byDefault = [
    Color(0xff00ca00),
    Color(0xff127cff),
    Color(0xfff21839),
    Color(0xffffc000),
  ];
}
