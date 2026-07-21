import 'package:flosu/models/beatmap/beatmap_content.dart';
import 'package:flosu/models/generated/beatmap_metadata.dart';
import 'package:flosu/models/replay/replay.dart';

abstract class IoResult<T> {
  IoResult({required this.id, required this.data});

  final String id;
  final T data;
}

class IoFailedResult extends IoResult<String> {
  IoFailedResult({required super.id, required this.error})
    : super(data: "Error: $error");

  final String error;
}

class IoBeatmapMetadataResult extends IoResult<BeatmapMetadata> {
  IoBeatmapMetadataResult({required super.id, required super.data});
}

class IoBeatmapContentResult extends IoResult<BeatmapContent> {
  IoBeatmapContentResult({required super.id, required super.data});
}

class IoReplayResult extends IoResult<Replay> {
  IoReplayResult({required super.id, required super.data});
}
