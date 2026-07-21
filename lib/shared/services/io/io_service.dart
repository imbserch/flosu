import 'dart:async';
import 'dart:isolate';

import 'package:file_picker/file_picker.dart';
import 'package:flosu/models/generated/beatmap_metadata.dart';
import 'package:flosu/shared/io/io_exceptions.dart';
import 'package:flosu/shared/services/io/io_commands.dart';
import 'package:flosu/shared/services/io/io_result.dart';
import 'package:flosu/shared/services/io/io_service_worker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Converts the file path and optional data into a [IoCommand].
///
/// [data] is optional and will be used by the parser to parse the file.
/// For example, if [path] ends with ".osu", [data] can be a [BeatmapMetadata] to
/// use for parsing the file.
IoCommand _getCommandFromData(String path, {required Object? data}) {
  final commandTimestamp = DateTime.now().microsecondsSinceEpoch;
  final id = "$commandTimestamp";

  return switch (path) {
    var _ when path.endsWith(".osu") =>
      data is BeatmapMetadata
          ? ParseBeatmapContentCommand(id, metadata: data)
          : ParseBeatmapMetadataCommand(id, path: path),
    var _ when path.endsWith(".osr") => ParseReplayCommand(id, path: path),
    var _ => throw IoCommandNotFoundException(path),
  };
}

class IoService {
  bool _initialized = false;

  Isolate? _isolate;
  SendPort? _commandsPort;
  final _receivePort = ReceivePort();
  final _ready = Completer<void>();

  final StreamController<IoResult> _resultController =
      StreamController<IoResult>.broadcast();

  Stream<IoResult> get resultStream => _resultController.stream;

  Future<void> init() async {
    if (_initialized) return;

    _isolate = await Isolate.spawn(
      ioWorker,
      _receivePort.sendPort,
      debugName: "I/O service",
    );

    _receivePort.listen((message) {
      switch (message) {
        case SendPort port:
          _commandsPort = port;
          _ready.complete();
          _initialized = true;
          break;
        case IoResult r:
          _resultController.add(r);
          break;
        default:
        // No-op
      }
    });

    await _ready.future;
  }

  /// Opens a file picker dialog to load a file.
  ///
  /// The current worker will try to infer the parser based on the file extension.
  /// For example, if [allowedExtensions] contains ".osr", the [ReplayParser] will be used.
  Future<void> pick({
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

    parse(res.files[0].path!);
  }

  /// Parses a file at the given [filePath].
  ///
  /// The current worker will try to infer the parser based on the file extension.
  /// For example, if [filePath] ends with ".osr", the [ReplayParser] will be used.
  Future<void> parse(String path, {Object? data}) async {
    _checkInitialized();

    try {
      // We need to send the data to the isolate so it can be parsed there
      final command = _getCommandFromData(path, data: data);
      _commandsPort!.send(command);
    } catch (e) {
      // Skip sending data again to isolate
      _resultController.add(
        IoFailedResult(id: "", error: "Failed to create command: $e"),
      );
    }
  }

  void dispose() {
    _checkInitialized();

    _isolate?.kill(priority: Isolate.immediate);
    _receivePort.close();
    _resultController.close();
  }

  void _checkInitialized() {
    const message = "I/O service not initialized. Please call init() first";

    assert(_initialized, message);
    if (!_initialized) throw Exception(message);
  }
}

// Riverpod I/O service
final ioProvider = Provider<IoService>((ref) {
  final service = IoService();

  ref.onDispose(service.dispose);
  return service;
});
