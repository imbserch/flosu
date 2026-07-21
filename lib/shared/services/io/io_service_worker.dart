import 'dart:isolate';

import 'package:flosu/models/beatmap/beatmap_content.dart';
import 'package:flosu/models/generated/beatmap_metadata.dart';
import 'package:flosu/models/replay/replay.dart';
import 'package:flosu/shared/io/beatmap_content_parser_experimental.dart';
import 'package:flosu/shared/io/beatmap_metadata_parser_experimental.dart';
import 'package:flosu/shared/io/io_exceptions.dart';
import 'package:flosu/shared/io/io_parser.dart';
import 'package:flosu/shared/io/replay_parser_experimental.dart';
import 'package:flosu/shared/services/io/io_commands.dart';
import 'package:flosu/shared/services/io/io_result.dart';

/// Retrieves the parser for the given command.
///
/// [T] is the expected return type of the parser.
IoParser _getParserForCommand<T>(IoCommand<T> command) {
  return switch (command) {
    ParseBeatmapContentCommand bc => BeatmapContentParser(bc.metadata),
    ParseBeatmapMetadataCommand bm => BeatmapMetadataParser(bm.path),
    ParseReplayCommand r => ReplayParser(r.path),
    _ => throw IoParserNotFoundException<T>(),
  };
}

IoResult _getResultFromParser<T>(String id, T result) {
  return switch (result) {
    BeatmapContent c => IoBeatmapContentResult(id: id, data: c),
    BeatmapMetadata b => IoBeatmapMetadataResult(id: id, data: b),
    Replay r => IoReplayResult(id: id, data: r),
    _ => throw IoUnsupportedOutputException<T>(),
  };
}

/// The entrypoint for I/O isolate
void ioWorker(SendPort mainSendPort) {
  final workerReceivePort = ReceivePort();

  mainSendPort.send(workerReceivePort.sendPort);

  /// Parses a file at the given message [filePath]
  workerReceivePort.listen((message) async {
    if (message is IoCommand) {
      late IoCommand command;

      // A I/O command is received, trying to parse the file
      try {
        command = message;

        final parser = _getParserForCommand(command);

        // The parser only will return an object
        // If this parser fails, it will throw an exception
        final parsed = await parser.parse();

        final result = _getResultFromParser(command.id, parsed);
        mainSendPort.send(result);
      } catch (e) {
        // If an error occurs, send the result with the error
        mainSendPort.send(IoFailedResult(id: command.id, error: "$e"));
      }
    }
  });
}
