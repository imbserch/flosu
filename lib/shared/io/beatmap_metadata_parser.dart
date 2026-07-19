import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:flosu/core/enums.dart';
import 'package:flosu/shared/io/parser.dart';
import 'package:flosu/models/generated/beatmap_metadata.dart';

class BeatmapMetadataParserException implements Exception {
  const BeatmapMetadataParserException(this.message);

  final String message;

  @override
  String toString() => "BeatmapMetadataParserException: $message";
}

class BeatmapMetadataParser extends Parser<BeatmapMetadata> {
  BeatmapMetadataParser(super.file);

  final metadata = BeatmapMetadata();

  /// Raw string content of the beatmap file.
  String _data = "";

  @override
  Future<bool> init() async {
    try {
      if (await file.exists()) {
        final bytes = await file.readAsBytes();

        // Set md5 and file path
        metadata
          ..filePath = super.file.path
          ..md5 = md5.convert(bytes).toString();

        _data = utf8.decode(bytes);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<BeatmapMetadata> parse() async {
    final sections = _data.split(RegExp(r'\n(?=\[.*\])'));

    for (final section in sections) {
      final lines = section.trim().split("\n");
      if (lines.isEmpty) continue;

      final header = lines[0].trim();
      final data = _cleanLines(lines.sublist(1));

      switch (header) {
        case "[General]":
          final props = _mapKey(data);

          // Mode defaults to 0 (osu! standard) if not specified in the file
          final mode = int.tryParse(props["Mode"] ?? "0") ?? 0;

          final audioFilename = props["AudioFilename"];
          final previewTime = int.tryParse(props["PreviewTime"] ?? "") ?? 0;

          //Return if mode isn't 0 (Osu)
          if (mode != 0) {
            throw const BeatmapMetadataParserException(
              "Tried to parse an incompatible osu! ruleset. Compatible modes: osu!",
            );
          }

          // Set properties
          metadata.general
            ..previewTime = previewTime
            ..audioPath = audioFilename != null
                ? "${super.file.parent.path}/$audioFilename"
                : null;
          break;
        case "[Metadata]":
          final props = _mapKey(data);

          final title = props["Title"] ?? "";
          final artist = props["Artist"] ?? "";
          final creator = props["Creator"] ?? "";
          final version = props["Version"] ?? "";
          final source = props["Source"] ?? "";
          final tags = props["Tags"] ?? "";

          final beatmapId = int.tryParse(props["BeatmapID"] ?? "");
          final beatmapSetId = int.tryParse(props["BeatmapSetID"] ?? "");

          metadata.info
            ..title = title
            ..artist = artist
            ..creator = creator
            ..version = version
            ..source = source
            ..tags = tags;

          metadata.general
            ..beatmapId = beatmapId
            ..beatmapSetId = beatmapSetId;

          break;
        case "[Difficulty]":
          final props = _mapKey(data);

          final approachRate =
              double.tryParse(props["ApproachRate"] ?? "") ?? 5;
          final circleSize = double.tryParse(props["CircleSize"] ?? "") ?? 5;
          final overallDifficulty =
              double.tryParse(props["OverallDifficulty"] ?? "") ?? 5;
          // The key in .osu files is 'HPDrainRate', not 'HPDrain'
          final hpDrain = double.tryParse(props["HPDrainRate"] ?? "") ?? 5;

          final sliderMultiplier =
              double.tryParse(props["SliderMultiplier"] ?? "") ?? 1;
          final sliderTickRate =
              double.tryParse(props["SliderTickRate"] ?? "") ?? 1;

          // Set properties
          metadata.difficulty
            ..ar = approachRate
            ..cs = circleSize
            ..od = overallDifficulty
            ..hp = hpDrain
            ..sliderMultiplier = sliderMultiplier
            ..sliderTickRate = sliderTickRate;
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
              metadata.general.backgroundPath =
                  "${super.file.parent.path}/$bgPath";
              break;
            }
          }
          break;
        case "[HitObjects]":
          final objectRows = _mapCommas(data);

          for (final row in objectRows) {
            final int bitmask = int.parse(row[3]);

            // Don't use this variable, this is intended
            // for updating the hit objects count
            final _ = switch (bitmask) {
              var c when HitObjectType.circle.existsIn(c) =>
                metadata.hitObjects.circles++,
              var sl when HitObjectType.slider.existsIn(sl) =>
                metadata.hitObjects.sliders++,
              var sp when HitObjectType.spinner.existsIn(sp) =>
                metadata.hitObjects.spinners++,
              _ => 0,
            };
          }
          break;
        default:
          break;
      }
    }

    return metadata;
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
