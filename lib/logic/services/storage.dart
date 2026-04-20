import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flosu/core/extensions.dart';
import 'package:flosu/models/storage/storage.dart';
import 'package:flosu/logic/providers/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();

  static final StorageService _instance = StorageService._();

  static StorageService get instance => _instance;

  Future<void> init() async {
    if (_prefs != null) {
      "Storage is already loaded. Skipping...".log;
    }

    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences? _prefs;

  String? getBeatmapsPath() => _prefs!.getString("beatmaps_path");

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

  Future<void> clearBeatmapsPath() async {
    await _prefs!.remove("beatmaps_path");

    //Force reload of beatmaps library
    "Beatmaps path removed. Refreshing...".log;
    final context = rootNavigatorKey.currentContext!;

    if (context.mounted) context.go("/splash");
  }

  Future<void> setAudioCompensation(int compensation) async {
    await _prefs!.setInt("audio_compensation", compensation.clamp(-200, 200));
  }

  Future<void> setGlobalVolume(double volume) async {
    await _prefs!.setDouble("global_volume", volume.clamp(0.0, 1.0));
  }

  Future<void> setMusicVolume(double volume) async {
    await _prefs!.setDouble("music_volume", volume.clamp(0.0, 1.0));
  }

  Future<void> setOsuK1(int keyId) async {
    await _prefs!.setInt("osu_k1", keyId);
  }

  Future<void> setOsuK2(int keyId) async {
    await _prefs!.setInt("osu_k2", keyId);
  }

  Future<void> setSnakingSliders(bool value) async {
    await _prefs!.setBool("snaking_sliders", value);
  }

  Future<void> setParallax(bool value) async {
    await _prefs!.setBool("parallax", value);
  }

  Future<void> setCursorTrail(bool value) async {
    await _prefs!.setBool("show_cursor_trail", value);
  }

  Future<void> setBackgroundDim(double value) async {
    await _prefs!.setDouble("background_dim", value.clamp(0.0, 1.0));
  }

  Future<void> setBackgroundBlur(double value) async {
    await _prefs!.setDouble("background_blur", value.clamp(0.0, 1.0));
  }

  Future<void> setBeatmapsPath(String? path) async {
    if (path == null) {
      await _prefs!.remove("beatmaps_path");
      return;
    }

    await _prefs!.setString(path, "beatmaps_path");
  }
}

final storageService = Provider<StorageService>(
  (ref) => StorageService.instance,
);
