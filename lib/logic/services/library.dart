import 'dart:io';

import 'package:flosu/core/extensions.dart';
import 'package:flosu/io/beatmap_parser.dart' show BeatmapParser;
import 'package:flosu/models/beatmap/beatmap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class LibraryService {
  LibraryService._();

  static final LibraryService _instance = LibraryService._();

  static LibraryService get instance => _instance;

  Future<void> init() async {
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

  Future<Beatmap?> getBeatmapFromFile(File file) async {
    try {
      //Check file extension
      if (!file.path.endsWith(".osu")) return null;

      final parser = BeatmapParser(file);

      if (!await parser.init()) {
        "Error reading beatmap\nPath: ${file.path}".log;
        return null;
      }

      return parser.parse();
    } catch (err) {
      "Error reading beatmap. Reason: $err\nPath: ${file.path}".log;
      return null;
    }
  }
}

final libraryService = Provider((ref) => LibraryService.instance);
