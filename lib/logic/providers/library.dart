import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flosu/logic/providers/router.dart';
import 'package:flosu/logic/providers/storage.dart';
import 'package:flosu/logic/services/file_parser.dart';
import 'package:flosu/logic/services/logger.dart';
import 'package:flosu/models/beatmap/beatmap.dart';
import 'package:flosu/models/beatmap/beatmap_set.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod notifier that maintains the in-memory beatmap library.
///
/// [LibraryProvider] watches the configured beatmaps directory from
/// [StorageProvider] and parses every `.osu` file it finds via
/// [FileParserService]. Parsed [Beatmap]s are grouped by title and artist
/// into [BeatmapSet]s, which are the items shown in the song selection list.
///
/// Parsing is performed asynchronously — the state grows incrementally as
/// files are parsed, so the UI can display results immediately without waiting
/// for the entire library to load.
class LibraryProvider extends Notifier<List<BeatmapSet>> {
  @override
  List<BeatmapSet> build() {
    Future.microtask(() async {
      // Subscribe to the file parser's result stream.
      final StreamSubscription<ParseResult> parserSubs = _parserService
          .resultStream
          .where((r) => r is ParseResult<Beatmap>)
          .listen(_handleParserResult);

      // Trigger a reload whenever the beatmaps directory path changes.
      ref.listen<String?>(
        storageProvider.select((it) => it.beatmapsPath),
        _listenStoragePathChanges,
        fireImmediately: true,
      );

      ref.onDispose(() {
        parserSubs.cancel();
        _logger.dispose();
      });
    });

    return [];
  }

  final ScopedLogger _logger = Logger.requestLogger("LibraryProvider");
  late final FileParserService _parserService = ref.read(fileParserService);

  /// Reacts to a change in the configured beatmaps directory path.
  ///
  /// Clears the current library and queues all `.osu` files in the new
  /// directory for parsing. If [path] is null or the directory does not exist,
  /// the library is cleared and no parsing is started.
  void _listenStoragePathChanges(String? old, String? path) async {
    if (path == null || path.isEmpty) {
      state = [];
      return;
    }

    final dir = Directory(path);
    if (!dir.existsSync()) {
      state = [];
      return;
    }

    // TODO: Add a DirectoryWatcher so new/removed files are detected at runtime.

    // Collect all .osu files recursively.
    final matchingFilePaths = dir
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()
        .where((file) => file.path.endsWith(".osu"))
        .map((file) => file.path);

    matchingFilePaths.forEach(_parserService.parseFile);
  }

  /// Handles a single [ParseResult] emitted by the [FileParserService].
  ///
  /// If the result contains a valid [Beatmap], it is inserted into the
  /// appropriate [BeatmapGroup] (or a new group is created if none exists).
  void _handleParserResult(ParseResult result) {
    if (result.hasError) {
      return _logger.error(
        "Failed to parse beatmap: ${result.error.toString()}",
      );
    }

    final beatmap = result.data;
    if (beatmap is! Beatmap) return;

    _logger.debug(
      "Beatmap parsed: ${beatmap.info.title} (${beatmap.info.version})",
    );

    _addBeatmapToState(beatmap);
  }

  /// Inserts a [Beatmap] into the state, creating or updating a [BeatmapSet].
  void _addBeatmapToState(Beatmap beatmap) {
    final title = beatmap.info.title;
    final artist = beatmap.info.artist;

    final groupIdx = state.indexWhere(
      (group) => group.title == title && group.artist == artist,
    );

    if (groupIdx != -1) {
      final updatedGroup = BeatmapSet([...state[groupIdx].beatmaps, beatmap]);

      state = [
        for (int idx = 0; idx < state.length; idx++)
          if (idx == groupIdx) updatedGroup else state[idx],
      ];
    } else {
      state = [
        ...state,
        BeatmapSet([beatmap]),
      ];
    }
  }

  /// Returns a randomly selected [Beatmap] from the entire library.
  ///
  /// Returns `null` if the library is empty.
  Beatmap? getRandom() {
    if (state.isEmpty) return null;

    int randomGroup = Random().nextInt(state.length);
    int randomBeatmap = Random().nextInt(state[randomGroup].beatmaps.length);

    return state[randomGroup].beatmaps[randomBeatmap];
  }

  void pickReplay() {
    globalRef
        .read(fileParserService)
        .pickFile(
          allowedExtensions: ["osr"],
          dialogTitle: "Select an Osu! replay file",
        );
  }
}

/// Global provider for [LibraryProvider].
final libraryProvider = NotifierProvider<LibraryProvider, List<BeatmapSet>>(
  () => LibraryProvider(),
);
