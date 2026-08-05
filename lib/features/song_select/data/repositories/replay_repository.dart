import 'package:collection/collection.dart';
import 'package:flosu/core/repositories/with_cache.dart';
import 'package:flosu/shared/domain/replay/replay.dart';
import 'package:flosu/shared/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReplayRepository extends RepositoryWithCache<List<Replay>> {
  // This class use io provider to send replay parse commands
  ReplayRepository(this.ref);

  final Ref ref;

  @override
  List<Replay> cache = [];

  @override
  bool get isInitialized => true;

  @override
  void init() {
    requestLogger();
    // Do nothing: Replays are only loaded when selected
  }

  /// Requests a replay file.
  ///
  /// If [path] is provided, it will be used to load the replay.
  /// If [path] is null, it will open a file picker to select a replay file.
  ///
  /// Returns the replay if successful, null otherwise.
  Future<Replay?> request({String? path}) async {
    final io = ref.read(ioProvider);

    final targetPath =
        path ??
        await io.pick(
          allowedExtensions: ["osr"],
          dialogTitle: "Select an Osu! replay file",
        );

    if (targetPath == null) return null;

    final cachedReplay = _findInCache(path: targetPath);
    if (cachedReplay != null) return cachedReplay;

    final result = await io.parse(targetPath);

    if (result is! IoReplayResult) {
      log("Failed to parse replay file", level: .error);
      return null;
    }

    final replay = result.data;
    cache = [...cache, replay];
    notify();

    return replay;
  }

  Replay? _findInCache({required String path}) {
    return cache.firstWhereOrNull((r) => r.filePath == path);
  }

  Future<void> insert(List<Replay> data) async {
    // No-op: Replays are loaded via IO
  }

  /// Clear the repository.
  Future<void> clear() async {
    log("Cleared replays from repository", level: .success);

    cache.clear();
    notify();
  }
}

final replayRepository = Provider.autoDispose<ReplayRepository>(
  // Keep alive because it is a singleton
  (ref) {
    final repository = ReplayRepository(ref);

    ref.keepAlive();
    ref.onDispose(repository.dispose);
    return repository;
  },
);
