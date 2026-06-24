import 'dart:async';
import 'dart:io';
import 'dart:isolate';

// import 'package:flosu/core/extensions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flosu/io/beatmap_parser.dart';
import 'package:flosu/io/parser.dart';
import 'package:flosu/io/replay_parser.dart';
import 'package:flosu/models/beatmap/beatmap.dart';
import 'package:flosu/models/replay/replay.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ParseResult<T extends Object> {
  ParseResult({required this.filePath, this.data, this.error});

  final String filePath;
  final T? data;
  final String? error;

  bool get hasError => error != null;
}

class _ParseCommand {
  _ParseCommand(this.filePath);

  final String filePath;
}

class FileParserService {
  Isolate? _isolate;
  SendPort? _commandsPort;
  final _receivePort = ReceivePort();
  final _ready = Completer<void>();

  final StreamController<ParseResult> _resultController =
      StreamController<ParseResult>.broadcast();

  Stream<ParseResult> get resultStream => _resultController.stream;

  Future<void> init() async {
    _isolate = await Isolate.spawn(
      _isolateWorker,
      _receivePort.sendPort,
      debugName: "FileParserService",
    );

    _receivePort.listen((message) {
      if (message is SendPort) {
        _commandsPort = message;
        _ready.complete();
      } else if (message is ParseResult) {
        _resultController.add(message);
      }
    });

    await _ready.future;
  }

  /// Opens a file picker dialog to load a file.
  ///
  /// The current worker will try to infer the parser based on the file extension.
  /// For example, if [allowedExtensions] contains ".osr", the [ReplayParser] will be used.
  Future<void> pickFile({
    List<String>? allowedExtensions,
    String? dialogTitle,
  }) async {
    await _ready.future;

    final res = await FilePicker.pickFiles(
      type: .custom,
      allowedExtensions: allowedExtensions,
      lockParentWindow: true,
      dialogTitle: dialogTitle ?? "Select file",
    );

    if (res == null) return;
    if (res.count == 0) return;

    parseFile(res.files[0].path!);
  }

  /// Parses a file at the given [filePath].
  ///
  /// The current worker will try to infer the parser based on the file extension.
  /// For example, if [filePath] ends with ".osr", the [ReplayParser] will be used.
  Future<void> parseFile(String filePath) async {
    await _ready.future;
    _commandsPort!.send(_ParseCommand(filePath));
  }

  void dispose() {
    _isolate?.kill(priority: Isolate.immediate);
    _receivePort.close();
    _resultController.close();
  }
}

/// The worker that parses files in a separate isolate.
void _isolateWorker(SendPort mainSendPort) {
  final workerReceivePort = ReceivePort();

  mainSendPort.send(workerReceivePort.sendPort);

  /// Parses a file at the given message [filePath]
  workerReceivePort.listen((message) async {
    if (message is _ParseCommand) {
      try {
        // Infer the parser based on the file extension.
        Parser? currentParser;

        final file = File(message.filePath);
        if (!file.existsSync()) {
          throw Exception("File isn't created yet");
        }

        if (message.filePath.endsWith(".osu")) {
          currentParser = BeatmapParser(file);
        }

        if (message.filePath.endsWith(".osr")) {
          currentParser = ReplayParser(file);
        }

        if (currentParser == null) {
          // If no parser is found, send the error
          throw StateError("Tried to parse an incompatible file");
        }

        if (!(await currentParser.init())) {
          throw StateError("The current parser can't be initialized");
        }

        final result = await currentParser.parse();

        if (result is Replay) {
          return mainSendPort.send(
            ParseResult<Replay>(filePath: message.filePath, data: result),
          );
        }

        if (result is Beatmap) {
          return mainSendPort.send(
            ParseResult<Beatmap>(filePath: message.filePath, data: result),
          );
        }

        throw StateError("Tried to send an unknown file type");
      } catch (e) {
        mainSendPort.send(
          ParseResult(
            filePath: message.filePath,
            error: "Error parsing ${message.filePath}: $e",
          ),
        );
      }
    }
  });
}

final fileParserService = Provider<FileParserService>((ref) {
  final service = FileParserService();
  service.init();

  ref.onDispose(service.dispose);
  return service;
});
