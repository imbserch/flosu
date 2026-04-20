import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flosu/logic/services/storage.dart';
import 'package:flosu/models/beatmap/beatmap.dart';
import 'package:flosu/core/extensions.dart';
import 'package:flosu/io/beatmap_parser.dart';
import 'package:permission_handler/permission_handler.dart';

/// Provider de almacenamiento de mapas de osu
/// Debe mantener todos los mapas de ritmo
final beatmapService = StateNotifierProvider((ref) {
  final storage = ref.watch(storageService);
  return BeatmapService(storage);
});

class BeatmapService extends StateNotifier<BeatmapLibraryState> {
  BeatmapService(this._storage) : super(BeatmapLibraryState());

  final StorageService _storage;

  ///Initializes the beatmap library
  ///
  ///You must call this function before calling ensureReady() or the
  ///app will loop in the splash screen
  Future<Stream<String>?> initialize() async {
    final savedPath = _storage.getBeatmapsPath();

    if (savedPath != null) {
      //Request storage permissions (if aplicable)
      await _requestPermissions();

      "Loading beatmaps".log;
      return _loadBeatmapsFrom(savedPath);
    } else {
      "No beatmaps directory detected. Please set one".log;
      _clear();
      return null;
    }
  }

  Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == .android) {
      "Target is android. Requesting storage permissions".log;

      //Request legacy permissions
      if (!await Permission.storage.isGranted) {
        await Permission.storage.request();

        if (!await Permission.storage.isGranted) {
          "App cannot read beatmaps using legacy permissions".log;
        } else {
          "App can read beatmaps using legacy permissions".log;
        }
      }

      //Request modern permissions
      if (!await Permission.manageExternalStorage.isGranted) {
        await Permission.manageExternalStorage.request();

        if (!await Permission.manageExternalStorage.isGranted) {
          "App cannot read beatmaps using modern permissions".log;
        } else {
          "App can read beatmaps using modern permissions".log;
        }
      }
    }
  }

  Stream<String> _loadBeatmapsFrom(String path) {
    final StreamController<String> controller = StreamController.broadcast();

    state = state.copyWith(isLoading: true, rootPath: path, errorMessage: null);

    final List<Beatmap> loadedMaps = [];

    BeatmapLibrary.scanDirectory(path).listen(
      (data) {
        controller.add(data.filePath);
        loadedMaps.add(data.beatmap);
      },
      onDone: () {
        state = state.copyWith(beatmaps: loadedMaps, isLoading: false);
        controller.close();
      },
      onError: (e, _) => state = state.copyWith(
        isLoading: false,
        errorMessage: "Error loading beatmaps: $e",
      ),
    );

    return controller.stream;
  }

  Beatmap? getRandomBeatmap() {
    if (state.beatmaps.isEmpty) return null;

    int randomGroup = Random().nextInt(state.asGroups.length);
    int randomBeatmap = Random().nextInt(state.asGroups[randomGroup].length);

    return state.asGroups[randomGroup][randomBeatmap];
  }

  void _clear() {
    state = state.copyWith(beatmaps: [], isLoading: false);
  }
}

//TODO: MOVE THIS
class BeatmapLibraryState {
  BeatmapLibraryState({
    this.rootPath,
    this.beatmaps = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final String? rootPath;
  final List<Beatmap> beatmaps;
  final bool isLoading;
  final String? errorMessage;

  BeatmapLibraryState copyWith({
    String? rootPath,
    List<Beatmap>? beatmaps,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BeatmapLibraryState(
      rootPath: rootPath ?? this.rootPath,
      beatmaps: beatmaps ?? this.beatmaps,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  List<List<Beatmap>> get asGroups => beatmaps
      .groupListsBy((bm) => (bm.groupId, bm.info.title))
      .values
      .toList();
}

class BeatmapLibrary {
  static Future<Beatmap?> getBeatmap(File file) async {
    //Re-check extension
    if (!file.path.endsWith(".osu")) return null;

    final parser = BeatmapParser(file);

    if (!await parser.init()) {
      "Error reading beatmap\nPath: ${file.path}".log;
      return null;
    }

    return parser.parse();
  }

  static Stream<({String filePath, Beatmap beatmap})> scanDirectory(
    String directory,
  ) async* {
    final entities = Directory(directory).list(recursive: true);

    await for (final entity in entities) {
      if (entity is! File) continue;
      if (!entity.path.endsWith(".osu")) continue;

      try {
        final result = await getBeatmap(entity);
        if (result == null) continue;

        yield (filePath: entity.uri.pathSegments.last, beatmap: result);
      } catch (e) {
        "Beatmap can't be processed: $e".log;
      }
    }
  }
}
