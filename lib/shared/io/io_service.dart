import 'dart:async';
import 'dart:isolate';

import 'package:file_picker/file_picker.dart';
import 'package:flosu/shared/domain/beatmap/beatmap.dart';
import 'package:flosu/shared/io/io_exceptions.dart';
import 'package:flosu/shared/io/io_commands.dart';
import 'package:flosu/shared/io/io_result.dart';
import 'package:flosu/shared/io/io_service_worker.dart';
import 'package:flosu/shared/logging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Converts the file path and optional data into a [IoCommand].
///
/// [data] is optional and will be used by the parser to parse the file.
/// For example, if [path] ends with ".osu", [data] can be a [BeatmapMetadata] to
/// use for parsing the file.
IoCommand _getCommandFromData(String path, {required Object? data}) {
  return switch (path) {
    var _ when path.endsWith(".osu") =>
      data is Beatmap
          ? ParseFullBeatmapCommand(path, beatmap: data)
          : ParseBeatmapCommand(path, path: path),
    var _ when path.endsWith(".osr") => ParseReplayCommand(path, path: path),
    var _ => throw IoCommandNotFoundException(path),
  };
}

class IoService with Logging {
  bool _initialized = false;

  Isolate? _isolate;
  SendPort? _commandsPort;
  final _receivePort = ReceivePort();
  final _ready = Completer<void>();

  final StreamController<IoResult> _resultController =
      StreamController<IoResult>.broadcast();

  final Map<String, Completer<IoResult>> _pendingRequests = {};

  Stream<IoResult> get resultStream => _resultController.stream;

  Future<void> init() async {
    if (_initialized) return;

    requestLogger();

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
          log("Received result from isolate: ${r.data}", level: .info);

          final completer = _pendingRequests.remove(r.id);

          if (completer != null && !completer.isCompleted) {
            log("Completing task for ${r.id}", level: .info);
            completer.complete(r);
          }

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
  Future<String?> pick({
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

    if (res == null || res.count == 0) return null;

    // Path
    return res.files[0].path;
  }

  /// Parses a file at the given [filePath].
  ///
  /// The current worker will try to infer the parser based on the file extension.
  /// For example, if [filePath] ends with ".osr", the [ReplayParser] will be used.
  Future<IoResult> parse(String path, {Object? data}) async {
    _checkInitialized();

    final completer = Completer<IoResult>();
    _pendingRequests[path] = completer;

    try {
      // We need to send the data to the isolate so it can be parsed there
      final command = _getCommandFromData(path, data: data);

      log("Sending command to isolate: $command", level: .info);
      _commandsPort!.send(command);

      return await completer.future;
    } catch (e) {
      _pendingRequests.remove(path);

      final message = "Failed to create command: $e";
      log(message, level: .error);

      // Skip sending data again to isolate
      final result = IoFailedResult(id: path, error: message);
      _resultController.add(result);

      return result;
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
