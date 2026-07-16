import 'package:flosu/logic/services/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// Provides helpers for reading individual beatmap files from disk.
///
/// Handles Android storage permissions at startup and exposes
/// [getBeatmapFromFile] for single-file parsing with timeout and error recovery.
///
/// The actual library scanning loop lives in [beatmapProvider]; this service
/// only handles the low-level file I/O.
class LibraryService {
  LibraryService._();

  static final LibraryService _instance = LibraryService._();

  static LibraryService get instance => _instance;

  final ScopedLogger _logger = Logger.requestLogger("LibraryService");

  /// Requests necessary storage permissions on Android.
  ///
  /// Requests both the legacy `READ_EXTERNAL_STORAGE` permission (pre-API 33)
  /// and the modern `MANAGE_EXTERNAL_STORAGE` permission (API 30+), then logs
  /// whether each was granted.
  ///
  /// No-op on platforms other than Android.
  Future<void> init() async {
    if (defaultTargetPlatform == .android) {
      bool granted = false;

      _logger.debug("Android target. Requesting permissions");

      // Legacy permission (Android 9 and below).
      if (!await Permission.storage.isGranted) {
        final status = await Permission.storage.request();
        if (status == PermissionStatus.granted) granted = true;
      }

      if (!granted || !await Permission.manageExternalStorage.isGranted) {
        final status = await Permission.manageExternalStorage.request();
        if (status == PermissionStatus.granted) granted = true;
      }

      if (granted) {
        return _logger.info("Library permissions granted (Granted by user)");
      }

      return _logger.error(
        "Library permissions denied (Denied by user or permission revoked)",
      );
    }

    _logger.warn("Library permissions granted (Not Android Platform)");
  }

  void dispose() {
    _logger.dispose();
  }
}

/// Global provider that exposes the [LibraryService] singleton.
final libraryService = Provider((ref) {
  final instance = LibraryService.instance;

  ref.onDispose(() => instance.dispose());
  return instance;
});
