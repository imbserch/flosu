import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Color, Offset;

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:flosu/core/constants.dart';
import 'package:flosu/core/enums.dart';
import 'package:flosu/core/math/conversion.dart';
import 'package:flosu/features/song_select/data/repositories/beatmap_repository.dart';
import 'package:flosu/shared/domain/beatmap/beatmap.dart';
import 'package:flosu/shared/domain/beatmap/hit_object/hit_object.dart';
import 'package:flosu/shared/io/io_exceptions.dart';
import 'package:flosu/shared/io/parsers/io_parser.dart';

class BeatmapParser extends IoParser<Beatmap> {
  BeatmapParser(super.path)
    : beatmap = Beatmap()..dbVersion = BeatmapRepository.dbVersion,
      newBeatmap = true;

  BeatmapParser.fromBeatmap(this.beatmap)
    : newBeatmap = false,
      super(beatmap.filePath ?? "");

  final Beatmap beatmap;
  final bool newBeatmap;

  @override
  Future<Beatmap> parse() async {
    // The Beatmap is already fully parsed, so we can return it.
    if (!newBeatmap && beatmap.canPlay) return beatmap;

    final file = File(path);

    if (!(await file.exists())) {
      throw IoFileReadException("File not found: $path");
    }

    final bytes = await file.readAsBytes();

    beatmap
      ..filePath = file.path
      ..hash = md5.convert(bytes).toString();

    // Split the file into sections based on headers like [General], [Metadata], etc.
    final sections = utf8.decode(bytes).split(RegExp(r'\n(?=\[.*\])'));

    for (final section in sections) {
      final lines = section.trim().split("\n");
      if (lines.isEmpty) continue;

      final header = lines[0].trim();
      final data = _cleanLines(lines.sublist(1));

      switch (header) {
        case "[General]":
          final props = _mapKey(data);

          // final mode = parseInt(props["Mode"], 0);
          final audioFilename = props["AudioFilename"];

          /* beatmap.ruleset = switch (mode) {
            0 => Ruleset.osu(),
            1 => Ruleset.taiko(),
            2 => Ruleset.catchTheBeat(),
            3 => Ruleset.mania(),
            _ => Ruleset.osu(),
          }; */

          beatmap
            ..previewTime = parseInt(props["PreviewTime"], -1)
            ..audioPath = audioFilename != null
                ? "${file.parent.path}/$audioFilename"
                : null
            ..difficulty.stackLeniency = parseDouble(
              props["StackLeniency"],
              .7,
            );
          break;
        case "[Metadata]":
          final props = _mapKey(data);

          beatmap
            // General info
            ..title = props["Title"] ?? ""
            ..artist = props["Artist"] ?? ""
            ..creator = props["Creator"] ?? ""
            ..version = props["Version"] ?? ""
            ..source = props["Source"] ?? ""
            ..tags = props["Tags"] ?? ""
            // ID's
            ..id = parseInt(props["BeatmapID"], -1)
            ..setId = parseInt(props["BeatmapSetID"], -1);
          break;
        case "[Difficulty]":
          final props = _mapKey(data);

          beatmap.difficulty
            ..approachRate = parseDouble(props["ApproachRate"], 5)
            ..circleSize = parseDouble(props["CircleSize"], 5)
            ..overallDifficulty = parseDouble(props["OverallDifficulty"], 5)
            ..hpDrain = parseDouble(props["HPDrainRate"], 5)
            ..sliderMultiplier = parseDouble(props["SliderMultiplier"], 1)
            ..sliderTickRate = parseDouble(props["SliderTickRate"], 1);
          break;
        case "[Colours]":

          // Format colors: Combo1 : 255,128,0
          final colorData = _mapKey(data).entries
              .where((e) => e.key.startsWith("Combo"))
              .map((e) => e.value.split(","))
              .toList();

          for (final c in colorData) {
            final color = Color.fromARGB(
              parseInt(c.elementAtOrNull(3), 255),
              parseInt(c.elementAtOrNull(0), 255),
              parseInt(c.elementAtOrNull(1), 255),
              parseInt(c.elementAtOrNull(2), 255),
            );

            beatmap.rawColors = [...beatmap.rawColors, color.toARGB32()];
          }
          break;
        case "[Events]":

          // Remove all sprite, animation and unused event types
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

          // Use first matching background image
          for (final row in rawEvents) {
            // 0 0 represents background events
            if (row[0] == "0" && row[1] == "0") {
              final bgPath = row[2].replaceAll("\"", "");

              // Set full path
              beatmap.backgroundPath = "${file.parent.path}/$bgPath";

              break;
            }
          }
          break;
        case "[TimingPoints]":
          // Skip if this is a new beatmap
          if (newBeatmap) break;

          // The beatmap is already fully parsed
          if (beatmap.canPlay) break;

          // Timing points define BPM changes and slider velocity multipliers.
          final rawTimingPoints = _mapCommas(data);

          for (final rawTiming in rawTimingPoints) {
            final time = parseDouble(rawTiming[0], 0);
            final beatLength = parseDouble(rawTiming[1], 0);
            final meter = parseInt(rawTiming[2], 4);
            final volume = parseDouble(rawTiming[5], 100);
            final inherited = parseInt(rawTiming[6], 1) == 0;

            final timing = switch (inherited) {
              true => InheritedTiming(time, beatLength, meter, volume, false),
              false => NormalTiming(time, beatLength, meter, volume, false),
            };

            beatmap.timings.add(timing);
          }
          break;
        case "[HitObjects]":
          final objectRows = _mapCommas(data);
          // Skip if this is a new beatmap
          if (newBeatmap) {
            for (final row in objectRows) {
              final int bitmask = int.parse(row[3]);

              final type = HitObjectType.getBaseType(bitmask);

              switch (type) {
                case HitObjectType.circle:
                  beatmap.hitCircleCount++;
                  break;
                case HitObjectType.slider:
                  beatmap.sliderCount++;
                  break;
                case HitObjectType.spinner:
                  beatmap.spinnerCount++;
                  break;
                default:
                  break;
              }
            }

            break;
          }

          // The beatmap is already fully parsed
          if (beatmap.canPlay) break;

          for (final row in objectRows) {
            final x = parseDouble(row[0], SPINNER_CENTRE.dx);
            final y = parseDouble(row[1], SPINNER_CENTRE.dy);

            final position = Offset(x, y);

            final int time = parseInt(row[2], -1);
            final int bitmask = parseInt(row[3], 0);

            final type = HitObjectType.getBaseType(bitmask);

            final newCombo = HitObjectType.startsNewCombo(bitmask);
            final comboSkip = HitObjectType.comboSkip(bitmask);

            final skip = comboSkip != 0
                ? comboSkip
                : newCombo
                ? 1
                : 0;

            final hitObject = switch (type) {
              HitObjectType.circle =>
                HitCircle()
                  ..time = time
                  ..position = position
                  ..comboSkip = skip,
              HitObjectType.slider => _parseSlider(
                time,
                position,
                row,
                beatmap,
              )..comboSkip = skip,
              HitObjectType.spinner =>
                Spinner()
                  ..time = time
                  ..endTime = parseInt(row[5], time)
                  ..position = position
                  ..comboSkip = skip,
              _ => null,
            };

            if (hitObject != null) {
              beatmap.hitObjects.add(hitObject);
            }
          }
        /* 
          int currentComboIdx = 0;
          int currentColorIdx = 0;

          final firstUPoint = timingPoints.whereType<UTimingPoint>().first;

          double lastUBeatLength = firstUPoint.beatLength;
          TimingPoint currentTiming = firstUPoint;
          int timingIdx = 0;

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
              metadata.difficulty.sliderMultiplier,
              metadata.difficulty.sliderTickRate,
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
              if (currentObject.hitTime - nextObject.hitTime > stackThreshold) {
                break;
              }

              //Check positions and update
              if ((currentObject.pos - nextObject.pos).distanceSquared < 4) {
                nextObject.stackIdx = currentObject.stackIdx + 1;
                currentObject = nextObject;
              }
            }
          }
          break; */
        default:
          break;
      }
    }

    return beatmap;
  }

  Slider _parseSlider(
    int time,
    Offset position,
    List<String> raw,
    Beatmap partial,
  ) {
    final rawData = raw[5].split("|");
    final slides = parseInt(raw[6], 1);
    final length = parseDouble(raw[7], 0);

    final type = rawData.removeAt(0);

    final normalTiming = partial.timings.whereType<NormalTiming>().lastWhere(
      (timing) => timing.time <= time,
      orElse: () =>
          partial.timings.whereType<NormalTiming>().firstOrNull ??
          const NormalTiming(-100000, 1000, 4, 100, false),
    );

    final inheritedTiming = partial.timings
        .whereType<InheritedTiming>()
        .lastWhere(
          (t) => t.time <= time && t.time >= normalTiming.time,
          orElse: () => const InheritedTiming(0, -100, 4, 100, false),
        );

    final double velocityMultiplier = (inheritedTiming.beatLength < 0)
        ? (-100.0 / inheritedTiming.beatLength)
        : 1.0;

    double pixelsPerBeat =
        100.0 * partial.difficulty.sliderMultiplier * velocityMultiplier;
    if (pixelsPerBeat <= 0) pixelsPerBeat = 100.0;

    final slideDuration = (length * normalTiming.beatLength) / pixelsPerBeat;

    final slider = Slider()
      ..time = time
      ..endTime = (time + (slideDuration * slides)).round()
      ..slides = slides
      ..position = position
      ..curveType = .parse(type);

    for (final pointString in rawData) {
      final rawPoint = pointString.split(":");

      slider.addPoint(
        Offset(parseDouble(rawPoint[0], 0), parseDouble(rawPoint[1], 0)),
      );
    }

    return slider;
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
