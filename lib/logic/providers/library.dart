import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flosu/logic/providers/router.dart';
import 'package:flosu/logic/providers/storage.dart';
import 'package:flosu/logic/services/database.dart';
import 'package:flosu/logic/services/file_parser.dart';
import 'package:flosu/logic/services/logger.dart';
import 'package:flosu/models/storage/beatmap_metadata.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

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
class LibraryProvider extends Notifier<List<BeatmapMetadata>> {
  @override
  List<BeatmapMetadata> build() {
    Future.microtask(() async {
      // Subscribe to the file parser's result stream.
      final StreamSubscription<ParseResult> parserSubs = _parserService
          .resultStream
          .where((r) => r is ParseResult<BeatmapMetadata>)
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
  late final Isar _db = ref.read(databaseService.select((it) => it.db));

  /// Reacts to a change in the configured beatmaps directory path.
  ///
  /// Clears the current library and queues all `.osu` files in the new
  /// directory for parsing. If [path] is null or the directory does not exist,
  /// the library is cleared and no parsing is started.
  void _listenStoragePathChanges(String? old, String? path) async {
    if (path == null || path.isEmpty) return _clearBeatmapsDB();

    final dir = Directory(path);
    if (!dir.existsSync()) return _clearBeatmapsDB();

    final storedBeatmaps = await _db.beatmapMetadatas.where().findAll();
    _addAndSort(storedBeatmaps);

    // Collect all .osu files recursively.
    final matchingPaths = dir
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()
        .where((file) => file.path.endsWith(".osu"))
        .map((file) => file.path);

    for (final path in matchingPaths) {
      final isNewFile = storedBeatmaps.none((it) => it.filePath == path);
      if (!isNewFile) continue;

      _parserService.parseFile(path, onlyMetadata: true);
    }
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
    if (beatmap is! BeatmapMetadata) return;

    _logger.debug(
      "Beatmap parsed: ${beatmap.info.title} (${beatmap.info.version})",
    );

    _addBeatmapToDB(beatmap);
  }

  void _addAndSort(List<BeatmapMetadata> metadatas) {
    final newState = [...state, ...metadatas];

    newState.sort((a, b) {
      final compareSetId = (a.general.beatmapSetId ?? -1).compareTo(
        b.general.beatmapSetId ?? -1,
      );
      if (compareSetId != 0) return compareSetId;

      final compareTitle = a.info.title.compareTo(b.info.title);
      if (compareTitle != 0) return compareTitle;

      final compareArtist = a.info.artist.compareTo(b.info.artist);
      if (compareArtist != 0) return compareArtist;

      // Compare version
      return a.info.version.compareTo(b.info.version);
    });

    state = newState;
  }

  void _addBeatmapToDB(BeatmapMetadata metadata) {
    _db.writeTxn(() => _db.beatmapMetadatas.put(metadata));
    _addAndSort([metadata]);
  }

  void _clearBeatmapsDB() {
    _db.writeTxn(() => _db.beatmapMetadatas.where().deleteAll());
    state = [];
  }

  /// Returns a randomly selected [Beatmap] from the entire library.
  ///
  /// Returns `null` if the library is empty.
  BeatmapMetadata? getRandom() {
    if (state.isEmpty) return null;
    int selectedIndex = Random().nextInt(state.length);

    return state[selectedIndex];

    /*  int selectedGroup = Random().nextInt(state.length);
    final group = state[selectedGroup];

    return group.beatmaps[selectedBeatmap]; */
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
final libraryProvider =
    NotifierProvider<LibraryProvider, List<BeatmapMetadata>>(
      () => LibraryProvider(),
    );
