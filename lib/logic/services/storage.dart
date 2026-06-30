import 'dart:async';
import 'package:flosu/logic/services/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flosu/models/storage/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Low-level persistence layer that reads and writes application settings using
/// [SharedPreferences].
///
/// [StorageService] is a singleton that must be initialised with [init] before
/// any settings can be read or written. All write methods are asynchronous and
/// do not affect the in-memory [Storage] state — that is managed by
/// [StorageNotifier].
class StorageService {
  StorageService._();

  static final StorageService _instance = StorageService._();
  static StorageService get instance => _instance;

  final ScopedLogger _logger = Logger.requestLogger("StorageService");

  /// Loads the [SharedPreferences] instance.
  ///
  /// Safe to call multiple times; subsequent calls are no-ops.
  Future<void> init() async {
    if (_prefs != null) {
      _logger.info("Storage is already loaded. Skipping...");
      return;
    }

    _prefs = await SharedPreferences.getInstance();
    _logger.info("Storage initialized");
  }

  /// Disposes the storage service.
  void dispose() => _logger.dispose();

  SharedPreferences? _prefs;

  void _logStorageChange(String key, dynamic oldValue, dynamic newValue) {
    _logger.debug("Storage changed: $key |  $oldValue => $newValue");
  }

  /// Reads all persisted settings and returns them as a [Storage] snapshot.
  ///
  /// Called once during app startup by [StorageNotifier] to populate its
  /// initial state.
  Storage getInitialStorage() {
    return Storage(
      beatmapsPath: _prefs!.getString("beatmaps_path"),
      audioCompensation: _prefs!.getInt("audio_compensation") ?? 0,
      globalVolume: _prefs!.getDouble("global_volume") ?? 1.0,
      musicVolume: _prefs!.getDouble("music_volume") ?? 1.0,
      osuK1: _prefs!.getInt("osu_k1") ?? 0x0000000007a /* Z */,
      osuK2: _prefs!.getInt("osu_k2") ?? 0x00000000078 /* X */,
      snakingSliders: _prefs!.getBool("snaking_sliders") ?? true,
      parallax: _prefs!.getBool("parallax") ?? true,
      backgroundDim: _prefs!.getDouble("background_dim") ?? 0.8,
      backgroundBlur: _prefs!.getDouble("background_blur") ?? 0.0,
      showCursorTrail: _prefs!.getBool("show_cursor_trail") ?? true,
      showLogs: _prefs!.getBool("show_logs") ?? false,
      showFpsMonitor: _prefs!.getBool("show_fps_monitor") ?? false,
    );
  }

  // Note:
  // Every set* method in this class first checks if the new value is equal
  // to the old value. If it is, it returns early to avoid writing to
  // [SharedPreferences] and logging an unnecessary change.

  /// Persists the audio timing compensation offset, clamped to ±200 ms.
  Future<void> setAudioCompensation(int compensation) async {
    final comp = compensation.clamp(-200, 200);
    final oldComp = _prefs!.getInt("audio_compensation");

    if (oldComp == comp) return;

    _logStorageChange("audio_compensation", oldComp, comp);
    await _prefs!.setInt("audio_compensation", comp);
  }

  /// Persists the master volume, clamped to [0.0, 1.0].
  Future<void> setGlobalVolume(double volume) async {
    final vol = volume.clamp(0.0, 1.0);
    final oldVol = _prefs!.getDouble("global_volume");

    if (oldVol == vol) return;

    _logStorageChange("global_volume", oldVol, vol);
    await _prefs!.setDouble("global_volume", vol);
  }

  /// Persists the music volume, clamped to [0.0, 1.0].
  Future<void> setMusicVolume(double volume) async {
    final vol = volume.clamp(0.0, 1.0);
    final oldVol = _prefs!.getDouble("music_volume");

    if (oldVol == vol) return;

    _logStorageChange("music_volume", oldVol, vol);
    await _prefs!.setDouble("music_volume", vol);
  }

  /// Persists the logical key code for K1.
  Future<void> setOsuK1(int keyId) async {
    final oldKeyId = _prefs!.getInt("osu_k1");

    if (oldKeyId == keyId) return;

    _logStorageChange("osu_k1", oldKeyId, keyId);
    await _prefs!.setInt("osu_k1", keyId);
  }

  /// Persists the logical key code for K2.
  Future<void> setOsuK2(int keyId) async {
    final oldKeyId = _prefs!.getInt("osu_k2");

    if (oldKeyId == keyId) return;

    _logStorageChange("osu_k2", oldKeyId, keyId);
    await _prefs!.setInt("osu_k2", keyId);
  }

  /// Persists the snaking-sliders preference.
  Future<void> setSnakingSliders(bool value) async {
    final oldVal = _prefs!.getBool("snaking_sliders");

    if (oldVal == value) return;

    _logStorageChange("snaking_sliders", oldVal, value);
    await _prefs!.setBool("snaking_sliders", value);
  }

  /// Persists the parallax preference.
  Future<void> setParallax(bool value) async {
    final oldVal = _prefs!.getBool("parallax");

    if (oldVal == value) return;

    _logStorageChange("parallax", oldVal, value);
    await _prefs!.setBool("parallax", value);
  }

  /// Persists the cursor-trail preference.
  Future<void> setCursorTrail(bool value) async {
    final oldVal = _prefs!.getBool("show_cursor_trail");

    if (oldVal == value) return;

    _logStorageChange("show_cursor_trail", oldVal, value);
    await _prefs!.setBool("show_cursor_trail", value);
  }

  /// Persists the background dim level, clamped to [0.0, 1.0].
  Future<void> setBackgroundDim(double value) async {
    final dim = value.clamp(0.0, 1.0);
    final oldDim = _prefs!.getDouble("background_dim");

    if (dim == oldDim) return;

    _logStorageChange("background_dim", oldDim, dim);
    await _prefs!.setDouble("background_dim", dim);
  }

  /// Persists the background blur strength, clamped to [0.0, 1.0].
  Future<void> setBackgroundBlur(double value) async {
    final blur = value.clamp(0.0, 1.0);
    final oldBlur = _prefs!.getDouble("background_blur");

    if (blur == oldBlur) return;

    _logStorageChange("background_blur", oldBlur, blur);
    await _prefs!.setDouble("background_blur", blur);
  }

  /// Persists the beatmaps directory path, or removes it if [path] is null.
  Future<void> setBeatmapsPath(String? path) async {
    final oldPath = _prefs!.getString("beatmaps_path");
    _logStorageChange("beatmaps_path", oldPath, path);
    if (path == null) {
      await _prefs!.remove("beatmaps_path");
      return;
    }

    await _prefs!.setString("beatmaps_path", path);
  }

  /// Persists the logs visibility preference.
  Future<void> setShowLogs(bool value) async {
    final oldVal = _prefs!.getBool("show_logs");

    if (oldVal == value) return;

    _logStorageChange("show_logs", oldVal, value);
    await _prefs!.setBool("show_logs", value);
  }

  /// Persists the FPS monitor visibility preference.
  Future<void> setShowFpsMonitor(bool value) async {
    final oldVal = _prefs!.getBool("show_fps_monitor");

    if (oldVal == value) return;

    _logStorageChange("show_fps_monitor", oldVal, value);
    await _prefs!.setBool("show_fps_monitor", value);
  }
}

/// Global provider that exposes the [StorageService] singleton.
final storageService = Provider<StorageService>((ref) {
  final instance = StorageService.instance;

  // Automatically dispose the logger when the provider is disposed.
  ref.onDispose(instance.dispose);

  return instance;
});
