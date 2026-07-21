import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flosu/shared/router.dart';
import 'package:flosu/features/settings/domain/settings.dart';
import 'package:flosu/logic/services/file_parser.dart';
import 'package:flosu/logic/services/logger.dart';
import 'package:flosu/models/generated/beatmap_metadata.dart';
import 'package:flosu/repositories/beatmap.dart';
import 'package:flosu/shared/services/io/io_result.dart';
import 'package:flosu/shared/services/io/io_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

///
class BeatmapProvider extends Notifier<List<BeatmapMetadata>> {
  late final BeatmapRepository _repository = ref.read(
    beatmapRepositoryProvider,
  );
  late final IoService _parserService = ref.read(fileParserService);

  final ScopedLogger _logger = Logger.requestLogger("BeatmapProvider");

  @override
  List<BeatmapMetadata> build() {
    Future.microtask(() async {
      // Subscribe to the file parser's result stream.
      final parserSubs = _parserService.resultStream
          .where((r) => r is IoBeatmapMetadataResult)
          .listen(_handleResult);

      // Subscribe to the repository stream.
      final beatmapSubs = _repository.stream.listen(_handleRepositoryUpdate);

      // Trigger a reload whenever the beatmaps directory path changes.
      ref.listen<String?>(
        settingsProvider.select((it) => it.beatmapsPath),
        _listenStoragePathChanges,
        fireImmediately: true,
      );

      ref.onDispose(() {
        beatmapSubs.cancel();
        parserSubs.cancel();
        _logger.dispose();
      });
    });

    return [];
  }

  /// Reacts to a change in the configured beatmaps directory path.
  ///
  /// Clears the current library and queues all `.osu` files in the new
  /// directory for parsing. If [path] is null or the directory does not exist,
  /// the library is cleared and no parsing is started.
  void _listenStoragePathChanges(String? old, String? path) async {
    if (path == null || path.isEmpty) return _clearRepository();

    final dir = Directory(path);
    if (!dir.existsSync()) return _clearRepository();

    final storedBeatmaps = _repository.cache;

    // Collect all .osu files recursively.
    final matchingPaths = dir
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()
        .where((file) => file.path.endsWith(".osu"))
        .map((file) => file.path);

    for (final path in matchingPaths) {
      final isNewFile = storedBeatmaps.none((it) => it.filePath == path);
      if (!isNewFile) continue;

      _parserService.parse(path);
    }
  }

  /// Handles a single [IoResult] emitted by the [IoService].
  void _handleResult(IoResult result) {
    assert(
      result is IoBeatmapMetadataResult,
      "Expected IoBeatmapMetadataResult. Got ${result.runtimeType}",
    );

    final metadata = result.data!;

    _logger.debug(
      "Beatmap parsed: ${metadata.info.title} (${metadata.info.version})",
    );

    // Add beatmap to DB and update state
    _repository.insert([metadata]);
  }

  void _handleRepositoryUpdate(List<BeatmapMetadata> metadatas) =>
      state = sort(metadatas);

  void _clearRepository() => _repository.clear();

  List<BeatmapMetadata> sort(List<BeatmapMetadata> beatmaps) =>
      beatmaps..sort((a, b) {
        final titleCompare = a.info.title.compareTo(b.info.title);
        if (titleCompare != 0) return titleCompare;

        final artistCompare = a.info.artist.compareTo(b.info.artist);
        if (artistCompare != 0) return artistCompare;

        final setIdCompare = (a.general.beatmapSetId ?? 0).compareTo(
          b.general.beatmapSetId ?? 0,
        );
        if (setIdCompare != 0) return setIdCompare;

        return a.info.version.compareTo(b.info.version);
      });

  /// Returns a randomly selected [Beatmap] from the entire library.
  ///
  /// Returns `null` if the library is empty.
  BeatmapMetadata? getRandom() {
    if (state.isEmpty) return null;
    int selectedIndex = Random().nextInt(state.length);

    return state[selectedIndex];
  }

  void pickReplay() {
    globalRef
        .read(fileParserService)
        .pick(
          allowedExtensions: ["osr"],
          dialogTitle: "Select an Osu! replay file",
        );
  }
}

/// Global provider for [BeatmapProvider].
final beatmapProvider =
    NotifierProvider<BeatmapProvider, List<BeatmapMetadata>>(
      () => BeatmapProvider(),
    );
