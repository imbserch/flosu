import 'package:flosu/shared/logging.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Provides helpers for reading individual beatmap files from disk.
///
/// Handles Android storage permissions at startup and exposes
/// [getBeatmapFromFile] for single-file parsing with timeout and error recovery.
///
/// The actual library scanning loop lives in [beatmapProvider]; this service
/// only handles the low-level file I/O.
class IoPermissionHandler with Logging {
  IoPermissionHandler._();

  static IoPermissionHandler get _instance => IoPermissionHandler._();

  /// Requests necessary storage permissions on Android.
  ///
  /// Requests both the legacy `READ_EXTERNAL_STORAGE` permission (pre-API 33)
  /// and the modern `MANAGE_EXTERNAL_STORAGE` permission (API 30+), then logs
  /// whether each was granted.
  ///
  /// No-op on platforms other than Android.
  static Future<void> init() async {
    _instance.requestLogger();

    if (defaultTargetPlatform != .android) {
      return _instance.log(
        "Library permissions granted (Not Android Platform)",
        level: .warning,
      );
    }

    _instance.log("Android target. Requesting permissions", level: .debug);
    bool granted = false;

    final storageStatus = await Permission.storage.request();
    final externalStorageStatus = await Permission.manageExternalStorage
        .request();

    final storageGranted = storageStatus == .granted;
    final externalStorageGranted = externalStorageStatus == .granted;

    granted = storageGranted || externalStorageGranted;

    if (!granted && !storageGranted) {
      // Legacy permission (Android 9 and below).
      granted = (await Permission.storage.request()) == .granted;
    }

    if (!granted && !externalStorageGranted) {
      // Modern permission (Android 9+).
      granted = (await Permission.manageExternalStorage.request()) == .granted;
    }

    if (granted) {
      _instance.log(
        "Library permissions granted (Granted by user)",
        level: .info,
      );
      return _instance.removeLogger();
    }

    _instance.log(
      "Library permissions denied (Denied by user or permission revoked)",
      level: .error,
    );
    _instance.removeLogger();
  }
}
