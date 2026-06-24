import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flosu/core/extensions.dart';
import 'package:flosu/logic/providers/router.dart';
import 'package:flosu/logic/providers/storage.dart';
import 'package:flosu/logic/services/file_parser.dart';
import 'package:flosu/models/beatmap/beatmap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod notifier that maintains the in-memory beatmap library.
///
/// [LibraryProvider] watches the configured beatmaps directory from
/// [StorageProvider] and parses every `.osu` file it finds via
/// [FileParserService]. Parsed [Beatmap]s are grouped by title and artist
/// into [BeatmapGroup]s, which are the items shown in the song selection list.
///
/// Parsing is performed asynchronously — the state grows incrementally as
/// files are parsed, so the UI can display results immediately without waiting
/// for the entire library to load.
class LibraryProvider extends Notifier<List<BeatmapGroup>> {
  @override
  List<BeatmapGroup> build() {
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

      ref.onDispose(parserSubs.cancel);
    });

    return [];
  }

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
      result.error.log;
      return;
    }

    final beatmap = result.data;
    if (beatmap is! Beatmap) return;

    "Beatmap parsed: ${beatmap.info.title} (${beatmap.info.version})".log;
    _addBeatmapToState(beatmap);
  }

  /// Inserts a [Beatmap] into the state, creating or updating a [BeatmapGroup].
  void _addBeatmapToState(Beatmap beatmap) {
    final title = beatmap.info.title;
    final artist = beatmap.info.artist;

    final groupIdx = state.indexWhere(
      (group) => group.title == title && group.artist == artist,
    );

    if (groupIdx != -1) {
      final updatedGroup = BeatmapGroup([...state[groupIdx].beatmaps, beatmap]);

      state = [
        for (int idx = 0; idx < state.length; idx++)
          if (idx == groupIdx) updatedGroup else state[idx],
      ];
    } else {
      state = [
        ...state,
        BeatmapGroup([beatmap]),
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
    // TODO: This will only pick .osr files, this needs replay flow implementation
    globalRef
        .read(fileParserService)
        .pickFile(
          allowedExtensions: ["osr"],
          dialogTitle: "Select an Osu! replay file",
        );
  }
}

/// Global provider for [LibraryProvider].
final libraryProvider = NotifierProvider<LibraryProvider, List<BeatmapGroup>>(
  () => LibraryProvider(),
);

// ---------------------------------------------------------------------------
// BeatmapGroup
// ---------------------------------------------------------------------------

/// A collection of [Beatmap]s that share the same song title and artist.
///
/// In osu! terminology this is analogous to a "beatmap set" — multiple
/// difficulty levels for the same song, shown as a single card in the list.
//TODO: Rename to Beatmapset
class BeatmapGroup {
  BeatmapGroup(this.beatmaps)
    : title = beatmaps.first.info.title,
      artist = beatmaps.first.info.artist;

  /// Shared song title for all beatmaps in this group.
  final String title;

  /// Shared artist name for all beatmaps in this group.
  final String artist;

  /// All parsed difficulty variants for this song, in insertion order.
  final List<Beatmap> beatmaps;
}
