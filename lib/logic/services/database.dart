import 'package:flosu/models/storage/beatmap_metadata.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  late final Isar _isar;

  Isar get db => _isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open([
      BeatmapMetadataSchema,
      // ReplayMetadataSchema,
    ], directory: dir.path);
  }
}

final databaseService = Provider((ref) => DatabaseService.instance);
