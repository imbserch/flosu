import 'package:flosu/models/beatmap/beatmap_content.dart';
import 'package:flosu/models/generated/beatmap_metadata.dart';
import 'package:flosu/models/replay/replay.dart';

abstract class IoCommand<T> {
  IoCommand(this.id);

  final String id;
}

class ParseBeatmapMetadataCommand extends IoCommand<BeatmapMetadata> {
  ParseBeatmapMetadataCommand(super.id, {required this.path});

  final String path;
}

class ParseBeatmapContentCommand extends IoCommand<BeatmapContent> {
  ParseBeatmapContentCommand(super.id, {required this.metadata});

  final BeatmapMetadata metadata;
}

class ParseReplayCommand extends IoCommand<Replay> {
  ParseReplayCommand(super.id, {required this.path});

  final String path;
}
