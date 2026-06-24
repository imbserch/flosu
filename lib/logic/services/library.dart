import 'dart:io';

import 'package:flosu/core/extensions.dart';
import 'package:flosu/io/beatmap_parser.dart' show BeatmapParser;
import 'package:flosu/models/beatmap/beatmap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// Provides helpers for reading individual beatmap files from disk.
///
/// Handles Android storage permissions at startup and exposes
/// [getBeatmapFromFile] for single-file parsing with timeout and error recovery.
///
/// The actual library scanning loop lives in [LibraryProvider]; this service
/// only handles the low-level file I/O.
class LibraryService {
  LibraryService._();

  static final LibraryService _instance = LibraryService._();

  static LibraryService get instance => _instance;

  /// Requests necessary storage permissions on Android.
  ///
  /// Requests both the legacy `READ_EXTERNAL_STORAGE` permission (pre-API 33)
  /// and the modern `MANAGE_EXTERNAL_STORAGE` permission (API 30+), then logs
  /// whether each was granted.
  ///
  /// No-op on platforms other than Android.
  Future<void> init() async {
    if (defaultTargetPlatform == .android) {
      "Target is android. Requesting storage permissions".log;

      // Legacy permission (Android 9 and below).
      if (!await Permission.storage.isGranted) {
        await Permission.storage.request();

        if (!await Permission.storage.isGranted) {
          "App cannot read beatmaps using legacy permissions".log;
        } else {
          "App can read beatmaps using legacy permissions".log;
        }
      }

      // Modern permission (Android 10+).
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

  /// Parses a single `.osu` [file] into a [Beatmap].
  ///
  /// Returns `null` if:
  /// - The file extension is not `.osu`.
  /// - The file cannot be opened (parser init fails).
  /// - Parsing times out after 30 seconds.
  /// - Any exception is thrown during parsing.
  Future<Beatmap?> getBeatmapFromFile(File file) async {
    try {
      if (!file.path.endsWith(".osu")) return null;

      final parser = BeatmapParser(file);

      if (!await parser.init()) {
        "Error reading beatmap\nPath: ${file.path}".log;
        return null;
      }

      return await parser.parse().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          "Parsing beatmap timed out\nPath: ${file.path}".log;
          return null;
        },
      );
    } catch (err) {
      "Error reading beatmap. Reason: $err\nPath: ${file.path}".log;
      return null;
    }
  }
}

/// Global provider that exposes the [LibraryService] singleton.
final libraryService = Provider((ref) => LibraryService.instance);
