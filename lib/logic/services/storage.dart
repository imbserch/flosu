import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flosu/core/extensions.dart';
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

  /// Loads the [SharedPreferences] instance.
  ///
  /// Safe to call multiple times; subsequent calls are no-ops.
  Future<void> init() async {
    if (_prefs != null) {
      "Storage is already loaded. Skipping...".log;
    }

    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences? _prefs;

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
    );
  }

  /// Persists the audio timing compensation offset, clamped to ±200 ms.
  Future<void> setAudioCompensation(int compensation) async {
    await _prefs!.setInt("audio_compensation", compensation.clamp(-200, 200));
  }

  /// Persists the master volume, clamped to [0.0, 1.0].
  Future<void> setGlobalVolume(double volume) async {
    await _prefs!.setDouble("global_volume", volume.clamp(0.0, 1.0));
  }

  /// Persists the music volume, clamped to [0.0, 1.0].
  Future<void> setMusicVolume(double volume) async {
    await _prefs!.setDouble("music_volume", volume.clamp(0.0, 1.0));
  }

  /// Persists the logical key code for K1.
  Future<void> setOsuK1(int keyId) async {
    await _prefs!.setInt("osu_k1", keyId);
  }

  /// Persists the logical key code for K2.
  Future<void> setOsuK2(int keyId) async {
    await _prefs!.setInt("osu_k2", keyId);
  }

  /// Persists the snaking-sliders preference.
  Future<void> setSnakingSliders(bool value) async {
    await _prefs!.setBool("snaking_sliders", value);
  }

  /// Persists the parallax preference.
  Future<void> setParallax(bool value) async {
    await _prefs!.setBool("parallax", value);
  }

  /// Persists the cursor-trail preference.
  Future<void> setCursorTrail(bool value) async {
    await _prefs!.setBool("show_cursor_trail", value);
  }

  /// Persists the background dim level, clamped to [0.0, 1.0].
  Future<void> setBackgroundDim(double value) async {
    await _prefs!.setDouble("background_dim", value.clamp(0.0, 1.0));
  }

  /// Persists the background blur strength, clamped to [0.0, 1.0].
  Future<void> setBackgroundBlur(double value) async {
    await _prefs!.setDouble("background_blur", value.clamp(0.0, 1.0));
  }

  /// Persists the beatmaps directory path, or removes it if [path] is null.
  Future<void> setBeatmapsPath(String? path) async {
    if (path == null) {
      await _prefs!.remove("beatmaps_path");
      return;
    }

    await _prefs!.setString("beatmaps_path", path);
  }
}

/// Global provider that exposes the [StorageService] singleton.
final storageService = Provider<StorageService>(
  (ref) => StorageService.instance,
);
