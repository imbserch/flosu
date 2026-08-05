import 'dart:io';
import 'dart:math' hide log;

import 'package:collection/collection.dart';
import 'package:flosu/features/settings/domain/settings_provider.dart';
import 'package:flosu/shared/io.dart' show IoBeatmapResult, IoResult;
import 'package:flosu/shared/io/io_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flosu/shared/logging.dart';
import 'package:flosu/shared/domain/beatmap/beatmap.dart';
import 'package:flosu/features/song_select/data/repositories/beatmap_repository.dart';

extension BeatmapRandomizer on List<Beatmap> {
  Beatmap? get random => isEmpty ? null : this[Random().nextInt(length)];
}

class BeatmapLibrary extends Notifier<List<Beatmap>> with Logging {
  late final BeatmapRepository _repository = ref.read(beatmapRepository);
  late final IoService _parserService = ref.read(ioProvider);

  @override
  List<Beatmap> build() {
    requestLogger();

    Future.microtask(() async {
      // Subscribe to the I/O parser's result stream.
      // This will catch any beatmap parsed by the parser.
      final parserSubs = _parserService.resultStream
          .where((r) => r is IoBeatmapResult)
          .listen(_updateRepository);

      // Subscribe to the repository changes.
      // Any call to I/O parser will eventually lead to an update here.
      final beatmapSubs = _repository.stream.listen(
        (beatmaps) => state = _sort(beatmaps),
      );

      // Trigger a reload whenever the beatmaps directory path changes.
      ref.listen<String?>(
        settingsProvider.select((it) => it.beatmapsPath),
        _listenDirectory,
        fireImmediately: true,
      );

      ref.onDispose(() {
        beatmapSubs.cancel();
        parserSubs.cancel();
        removeLogger();
      });
    });

    return [];
  }

  /// Picks a beatmap from storage using a file picker dialog.
  ///
  /// Any beatmaps parsed by the I/O parser will be added to
  /// the repository and the state.
  void pick() {
    ref
        .read(ioProvider)
        .pick(allowedExtensions: ["osu"], dialogTitle: "Select a beatmap file");
  }

  void _listenDirectory(String? old, String? path) async {
    if (path == null) {
      state = [];
      return;
    }

    final dir = Directory(path);

    if (!(await dir.exists())) {
      state = [];
      return;
    }

    final fileStream = dir
        .list(recursive: true, followLinks: false)
        .where((type) => type is File && type.path.endsWith(".osu"));

    await for (final file in fileStream) {
      final name = file.path.split(RegExp(r"[/\\]")).last;

      final match = _repository.cache.firstWhereOrNull(
        (b) => b.filePath == file.path,
      );

      if (match == null) {
        _parserService.parse(file.path);
        log("Queued beatmap \"$name\" for parsing", level: .info);
        continue;
      }

      if (match.dbVersion < BeatmapRepository.dbVersion) {
        _parserService.parse(file.path);
        log("Queued beatmap \"$name\" for update", level: .info);
        continue;
      }
    }
  }

  void _updateRepository(IoResult result) {
    assert(
      result is IoBeatmapResult,
      "Expected IoBeatmapResult. Got ${result.runtimeType}",
    );

    final beatmap = result.data as Beatmap;
    final name = beatmap.filePath?.split(RegExp(r"[/\\]")).last;

    log("Beatmap parsed: \"$name\"", level: .debug);

    // Add beatmap to DB
    _repository.insert([beatmap]);
  }

  List<Beatmap> _sort(List<Beatmap> beatmaps) => beatmaps
    ..sort((a, b) {
      final titleCompare = a.title.compareTo(b.title);
      if (titleCompare != 0) return titleCompare;

      final artistCompare = a.artist.compareTo(b.artist);
      if (artistCompare != 0) return artistCompare;

      final setIdCompare = (a.setId).compareTo(b.setId);
      if (setIdCompare != 0) return setIdCompare;

      return a.version.compareTo(b.version);
    });
}

final beatmapLibrary = NotifierProvider(() => BeatmapLibrary());
