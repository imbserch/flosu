import 'dart:async';

import 'package:flosu/models/generated/beatmap_metadata.dart';
import 'package:flosu/repositories/base.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

class BeatmapRepository extends CachedRepository<List<BeatmapMetadata>> {
  Isar? _db;

  @override
  List<BeatmapMetadata> cache = [];

  @override
  bool isInitialized = false;

  @override
  FutureOr<void> init() async {
    super.init();

    final dir = await getApplicationDocumentsDirectory();
    _db = await Isar.open([BeatmapMetadataSchema], directory: dir.path);

    await get();
    isInitialized = true;
  }

  @override
  FutureOr<void> get() async {
    _ensureInitialized();

    final beatmaps = await _db!.beatmapMetadatas.where().findAll();
    log("Retrieved ${beatmaps.length} beatmaps from DB");

    cache = List.from(beatmaps);
    notify();
  }

  @override
  FutureOr<void> update(List<BeatmapMetadata> data) async {
    _ensureInitialized();

    /* await _db!.writeTxn(
      () => _db!.beatmapMetadatas.putAll(data),
    );
    cache.clear();
    cache.addAll(data); */
  }

  /// Inserts new beatmaps into the repository.
  Future<void> insert(List<BeatmapMetadata> beatmaps) async {
    _ensureInitialized();

    await _db!.writeTxn(() => _db!.beatmapMetadatas.putAll(beatmaps));
    log("Inserted ${beatmaps.length} beatmaps into DB");

    cache.addAll(beatmaps);
    notify();
  }

  /// Clear the repository.
  Future<void> clear() async {
    _ensureInitialized();

    await _db!.writeTxn(() => _db!.beatmapMetadatas.clear());
    log("Cleared beatmaps from DB");

    cache.clear();
    notify();
  }

  void _ensureInitialized() {
    if (_db == null) {
      const message =
          "Repository not initialized. "
          "Call init() first.";

      log(message, level: .error);
      throw Exception(message);
    }
  }
}

final beatmapRepositoryProvider = Provider<BeatmapRepository>(
  (ref) => throw UnimplementedError(
    "BeatmapRepositoryProvider needs to be overriden in ProviderScope",
  ),
);
