import 'package:flosu/shared/domain/beatmap/beatmap.dart';
import 'package:flosu/shared/domain/replay/replay.dart';

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

class IoBeatmapResult extends IoResult<Beatmap> {
  IoBeatmapResult({required super.id, required super.data});
}

class IoReplayResult extends IoResult<Replay> {
  IoReplayResult({required super.id, required super.data});
}
