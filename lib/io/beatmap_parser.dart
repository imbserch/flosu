import 'dart:convert';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:flosu/core/enums.dart';
import 'package:flosu/models/beatmap/beatmap.dart';
import 'package:flosu/models/beatmap/hit_objects.dart';
import 'package:flosu/core/extensions.dart';
import 'package:flosu/io/parser.dart';

/// A parser responsible for converting `.osu` file content into a [Beatmap] object.
class BeatmapParser extends Parser<Beatmap> {
  BeatmapParser(super.file);

  /// Raw string content of the beatmap file.
  String _data = "";

  /// Reads the file content and generates an MD5 hash for identification.
  @override
  Future<bool> init() async {
    try {
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        md5Hash = md5.convert(bytes).toString();
        _data = utf8.decode(bytes);
        return true;
      }
      return false;
    } catch (_) {
      "Error scanning ${file.path}".log;
      return false;
    }
  }

  /// Parses the loaded [_data] into a structured [Beatmap] object.
  @override
  Future<Beatmap?> parse() async {
    late int groupId;

    late BeatmapAudio audio;
    late BeatmapInfo info;
    late BeatmapDifficulty difficulty;
    double stackLeniency = .7;

    List<TimingPoint> timingPoints = [];
    List<Color> colors = BeatmapColors.byDefault;
    List<HitObject> objects = [];
    List<BeatmapEvent> events = [];

    try {
      // Split the file into sections based on headers like [General], [Metadata], etc.
      final sections = _data.split(RegExp(r'\n(?=\[.*\])'));

      for (final section in sections) {
        final lines = section.trim().split("\n");
        if (lines.isEmpty) continue;

        final header = lines[0].trim();
        final data = _cleanLines(lines.sublist(1));

        switch (header) {
          case "[General]":
            final generalData = _mapKey(data);

            //Return if mode isn't 0 (Osu)
            if (generalData["Mode"] != '0') return null;

            stackLeniency =
                double.tryParse(generalData["StackLeniency"] ?? ".7") ?? .7;

            audio = BeatmapAudio.fromMap(generalData, file.parent.path);
            break;
          case "[Editor]":
            break;
          case "[Metadata]":
            final meta = _mapKey(data);
            info = BeatmapInfo.fromMap(meta);

            //Get BeatmapSetID
            groupId = int.parse(meta["BeatmapSetID"] ?? "0");
            break;
          case "[Difficulty]":
            difficulty = BeatmapDifficulty.fromMap(_mapKey(data));
            break;
          case "[Events]":
            final rawEvents = _mapCommas(data).whereNot(
              (el) => [
                "Sprite",
                "Animation",
                "F",
                "M",
                "S",
                "V",
                "R",
                "C",
                "L",
                "T",
                "P",
              ].contains(el[0]),
            );

            events = rawEvents
                .map((ev) => BeatmapEvent.fromList(ev, file.parent.path))
                .nonNulls
                .toList();
            break;
          case "[TimingPoints]":
            // Timing points define BPM changes and slider velocity multipliers.
            final rawTimingPoints = _mapCommas(data);

            timingPoints = rawTimingPoints
                .map((t) => TimingPoint.fromList(t))
                .toList();
            break;
          case "[Colours]":
            // Format colors: Combo1 : 255,128,0
            final colorData = _mapKey(data).entries
                .where((e) => e.key.startsWith("Combo"))
                .map((e) => e.value.split(","))
                .toList();

            //Parse colors
            colors = colorData.isEmpty
                ? BeatmapColors.byDefault
                : BeatmapColors.fromList(colorData);
            break;
          case "[HitObjects]":
            final stackThreshold = difficulty.preempt * stackLeniency;

            int currentComboIdx = 0;
            int currentColorIdx = 0;

            final firstUPoint = timingPoints.whereType<UTimingPoint>().first;

            double lastUBeatLength = firstUPoint.beatLength;
            TimingPoint currentTiming = firstUPoint;
            int timingIdx = 0;

            final objectRows = _mapCommas(data);

            // First pass: Parse raw data into HitObject instances and handle combo colors.
            for (final row in objectRows) {
              final int hitTime = int.parse(row[2]);
              final int bitmask = int.parse(row[3]);
              final bool isNewCombo = HitObjectType.newCombo.existsIn(bitmask);

              if (isNewCombo) {
                currentComboIdx = 1;

                final int skip = HitObjectType.comboSkip(bitmask);
                currentColorIdx = (currentColorIdx + skip + 1) % colors.length;
              } else {
                currentComboIdx++;
              }

              while (timingIdx < timingPoints.length &&
                  timingPoints[timingIdx].time <= hitTime) {
                currentTiming = timingPoints[timingIdx];

                if (currentTiming is UTimingPoint) {
                  lastUBeatLength = currentTiming.beatLength;
                }
                timingIdx++;
              }

              final obj = HitObject.fromList(
                row,
                colors[currentColorIdx],
                currentComboIdx,
                currentTiming,
                lastUBeatLength,
                difficulty.sliderMultiplier,
                difficulty.sliderTickRate,
              );

              if (obj != null) objects.add(obj);
            }

            if (stackLeniency == 0) break;

            // Second pass: Calculate stack indices for overlapping objects.
            for (int i = objects.length - 1; i > 0; i--) {
              HitObject currentObject = objects.reversed.elementAt(i);

              //If already processed, skip
              if (currentObject.stackIdx != 0 && currentObject is! Slider) {
                continue;
              }

              if (currentObject is Spinner) {
                currentObject.stackIdx = 0;
              }

              for (int n = i - 1; n >= 0; n--) {
                HitObject nextObject = objects.reversed.elementAt(n);

                //If time difference > threshold, skip
                if (currentObject.hitTime - nextObject.hitTime >
                    stackThreshold) {
                  break;
                }

                //Check positions and update
                if ((currentObject.pos - nextObject.pos).distanceSquared < 4) {
                  nextObject.stackIdx = currentObject.stackIdx + 1;
                  currentObject = nextObject;
                }
              }
            }
            break;
          default:
            break;
        }
      }

      return Beatmap(
        fileHash,
        groupId,
        info,
        audio,
        difficulty,
        timingPoints,
        colors,
        events,
        objects,
      );
    } catch (e, s) {
      "Error parsing file: $e".log;
      "Stack: $s".log;
      return null;
    }
  }

  /// Removes empty lines and comments from the raw section data.
  List<String> _cleanLines(List<String> lines) => lines
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty && !l.startsWith("//"))
      .toList();

  /// Converts "Key: Value" lines into a Map.
  Map<String, String> _mapKey(List<String> lines) => {
    for (final line in lines)
      if (line.contains(":"))
        line.split(":")[0].trim(): line.substring(line.indexOf(":") + 1).trim(),
  };

  /// Splits comma-separated lines into lists of strings.
  List<List<String>> _mapCommas(List<String> lines) =>
      lines.map((l) => l.split(",").map((s) => s.trim()).toList()).toList();
}
