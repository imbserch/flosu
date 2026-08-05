import 'package:flosu/shared/domain/beatmap/beatmap.dart';
import 'package:flosu/shared/domain/replay/replay.dart';

abstract class IoCommand<T> {
  IoCommand(this.id);

  final String id;
}

class ParseFullBeatmapCommand extends IoCommand<Beatmap> {
  ParseFullBeatmapCommand(super.id, {required this.beatmap});

  final Beatmap beatmap;
}

class ParseBeatmapCommand extends IoCommand<Beatmap> {
  ParseBeatmapCommand(super.id, {required this.path});

  final String path;
}

class ParseReplayCommand extends IoCommand<Replay> {
  ParseReplayCommand(super.id, {required this.path});

  final String path;
}
