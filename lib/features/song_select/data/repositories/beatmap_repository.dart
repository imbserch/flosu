import 'dart:async';

import 'package:flosu/core/repositories/with_cache.dart';
import 'package:flosu/shared/domain/beatmap/beatmap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BeatmapRepository extends RepositoryWithCache<List<Beatmap>> {
  Isar? _db;

  @override
  List<Beatmap> cache = [];

  static int get dbVersion => 4;

  @override
  bool isInitialized = false;

  @override
  FutureOr<void> init() async {
    super.init();

    if (isInitialized) {
      return log("Repository already initialized", level: .warning);
    }

    final dir = await getApplicationDocumentsDirectory();
    _db = await Isar.open([BeatmapSchema], directory: dir.path);

    await _checkSchemaChanged();

    listenDBChanges();
    isInitialized = true;

    log("Repository initialized", level: .success);
  }

  Future<void> _checkSchemaChanged() async {
    log("##########      Check database version      ##########", level: .info);

    final prefs = SharedPreferencesAsync();
    final currentDbVersion = await prefs.getInt("dbVersion") ?? 0;

    if (currentDbVersion != dbVersion) {
      prefs.setInt("dbVersion", dbVersion);

      if (currentDbVersion < dbVersion) {
        log(
          "Database version updated. [BeatmapProvider] will update beatmaps soon",
          level: .warning,
        );
      }

      if (currentDbVersion > dbVersion) {
        log(
          "Using an old beatmap database version ($currentDbVersion > $dbVersion). "
          "Beatmaps should work, but it is recommended to delete the default.isar file",
          level: .warning,
        );
      }
    }

    log("##########    End check database version    ##########", level: .info);
  }

  void listenDBChanges() {
    _ensureInitialized();

    final query = _db!.beatmaps.where().build();

    query.watch(fireImmediately: true).listen((collection) {
      cache = List.of(collection);
      notify();
    });
  }

  /// Inserts new beatmaps into the repository.
  Future<void> insert(List<Beatmap> data) async {
    _ensureInitialized();

    await _db!.writeTxn(() => _db!.beatmaps.putAll(data));
    log("Inserted ${data.length} beatmaps into DB", level: .success);
  }

  /// Clear the repository.
  Future<void> clear() async {
    _ensureInitialized();

    await _db!.writeTxn(() => _db!.beatmaps.clear());
    log("Cleared beatmaps from DB", level: .success);

    cache.clear();
    notify();
  }

  void _ensureInitialized() {
    if (_db == null) {
      const message = "Repository not initialized. Call init() first.";

      log(message, level: .error);
      throw Exception(message);
    }
  }
}

final beatmapRepository = Provider.autoDispose<BeatmapRepository>(
  // Keep alive because it is a singleton
  (ref) {
    final repository = BeatmapRepository();

    ref.keepAlive();
    ref.onDispose(repository.dispose);
    return repository;
  },
);
