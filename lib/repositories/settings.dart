import 'dart:async';

import 'package:flosu/core/enums.dart';
import 'package:flosu/models/repositories/settings.dart';
import 'package:flosu/repositories/base.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Settings keys:
// beatmaps_path                 (String)
// audio_compensation            (int)
// global_volume                 (double)
// music_volume                  (double)
// osu_keys                      (List<String>)
// snaking_sliders_enabled       (bool)
// parallax_enabled              (bool)
// background_dim               (double)
// background_blur              (double)
// cursor_trail_enabled         (bool)
// logs_enabled                 (bool)
// fps_monitor_enabled          (bool)

/// A [Repository] for managing [Settings].
class SettingsRepository extends DebouncedRepository<Settings> {
  /// The instance of local preferences
  SharedPreferencesAsync? _asyncPrefs;

  @override
  bool isInitialized = false;

  @override
  Duration get delay => Durations.medium1;

  @override
  FutureOr<void> init() async {
    super.init();

    _asyncPrefs = SharedPreferencesAsync();

    // Fetch settings from local storage
    await get();
    isInitialized = true;
  }

  /// Sets the value of a setting.
  void set(SettingsKey key, Object? value) async {
    if (cache == null) return;

    late Settings newSettings;

    switch (key) {
      case .beatmapsPath:
        newSettings = cache!.copyWith(
          beatmapsPath: value as String?,
          keepLastBeatmapsPath: false,
        );
        break;
      case .audioCompensation:
        newSettings = cache!.copyWith(audioCompensation: value as int);
        break;
      case .globalVolume:
        newSettings = cache!.copyWith(globalVolume: value as double);
        break;
      case .musicVolume:
        newSettings = cache!.copyWith(musicVolume: value as double);
        break;
      case .osuKeys:
        newSettings = cache!.copyWith(osuKeys: (value as List).cast<int>());
        break;
      case .snakingSlidersEnabled:
        newSettings = cache!.copyWith(snakingSlidersEnabled: value as bool);
        break;
      case .parallaxEnabled:
        newSettings = cache!.copyWith(parallaxEnabled: value as bool);
        break;
      case .backgroundDim:
        newSettings = cache!.copyWith(backgroundDim: value as double);
        break;
      case .backgroundBlur:
        newSettings = cache!.copyWith(backgroundBlur: value as double);
        break;
      case .cursorTrailEnabled:
        newSettings = cache!.copyWith(cursorTrailEnabled: value as bool);
        break;
      case .logsEnabled:
        newSettings = cache!.copyWith(logsEnabled: value as bool);
        break;
      case .fpsMonitorEnabled:
        newSettings = cache!.copyWith(fpsMonitorEnabled: value as bool);
        break;
    }

    // Set new cache
    await update(newSettings);
  }

  @override
  Future<void> setUpdate(Settings data) async {
    final oldCache = commitedCache;

    super.setUpdate(data);
    _ensureInitialized();

    // If old cache is null, write all data
    if (oldCache == null) {
      log("Writing all settings data");
      return _writeAll(data);
    }

    log("Saving settings data");

    // Compare properties in memory and save only what changed
    if (oldCache.beatmapsPath != data.beatmapsPath) {
      if (data.beatmapsPath == null) {
        await _asyncPrefs!.remove(SettingsKey.beatmapsPath.name);
      } else {
        await _asyncPrefs!.setString(
          SettingsKey.beatmapsPath.name,
          data.beatmapsPath!,
        );
      }
    }
    if (oldCache.audioCompensation != data.audioCompensation) {
      await _asyncPrefs!.setInt(
        SettingsKey.audioCompensation.name,
        data.audioCompensation,
      );
    }
    if (oldCache.globalVolume != data.globalVolume) {
      await _asyncPrefs!.setDouble(
        SettingsKey.globalVolume.name,
        data.globalVolume,
      );
    }
    if (oldCache.musicVolume != data.musicVolume) {
      await _asyncPrefs!.setDouble(
        SettingsKey.musicVolume.name,
        data.musicVolume,
      );
    }
    if (oldCache.snakingSlidersEnabled != data.snakingSlidersEnabled) {
      await _asyncPrefs!.setBool(
        SettingsKey.snakingSlidersEnabled.name,
        data.snakingSlidersEnabled,
      );
    }
    if (oldCache.parallaxEnabled != data.parallaxEnabled) {
      await _asyncPrefs!.setBool(
        SettingsKey.parallaxEnabled.name,
        data.parallaxEnabled,
      );
    }
    if (oldCache.backgroundDim != data.backgroundDim) {
      await _asyncPrefs!.setDouble(
        SettingsKey.backgroundDim.name,
        data.backgroundDim,
      );
    }
    if (oldCache.backgroundBlur != data.backgroundBlur) {
      await _asyncPrefs!.setDouble(
        SettingsKey.backgroundBlur.name,
        data.backgroundBlur,
      );
    }
    if (oldCache.cursorTrailEnabled != data.cursorTrailEnabled) {
      await _asyncPrefs!.setBool(
        SettingsKey.cursorTrailEnabled.name,
        data.cursorTrailEnabled,
      );
    }
    if (oldCache.logsEnabled != data.logsEnabled) {
      await _asyncPrefs!.setBool(
        SettingsKey.logsEnabled.name,
        data.logsEnabled,
      );
    }
    if (oldCache.fpsMonitorEnabled != data.fpsMonitorEnabled) {
      await _asyncPrefs!.setBool(
        SettingsKey.fpsMonitorEnabled.name,
        data.fpsMonitorEnabled,
      );
    }

    if (!listEquals(oldCache.osuKeys, data.osuKeys)) {
      // Convert int to String to store in SharedPreferences
      final osuKeys = data.osuKeys.map((it) => it.toString()).toList();
      await _asyncPrefs!.setStringList(SettingsKey.osuKeys.name, osuKeys);
    }
  }

  @override
  Future<void> get() async {
    _ensureInitialized();

    log("Requesting all settings from [SharedPreferencesAsync]");

    final keys = await _asyncPrefs!.getAll();
    final rawOsuKeys = keys[SettingsKey.osuKeys.name] as List?;

    final loadedSettings = Settings().copyWith(
      audioCompensation: keys[SettingsKey.audioCompensation.name] as int?,
      globalVolume: keys[SettingsKey.globalVolume.name] as double?,
      musicVolume: keys[SettingsKey.musicVolume.name] as double?,
      snakingSlidersEnabled:
          keys[SettingsKey.snakingSlidersEnabled.name] as bool?,
      parallaxEnabled: keys[SettingsKey.parallaxEnabled.name] as bool?,
      backgroundDim: keys[SettingsKey.backgroundDim.name] as double?,
      backgroundBlur: keys[SettingsKey.backgroundBlur.name] as double?,
      cursorTrailEnabled: keys[SettingsKey.cursorTrailEnabled.name] as bool?,
      logsEnabled: keys[SettingsKey.logsEnabled.name] as bool?,
      fpsMonitorEnabled: keys[SettingsKey.fpsMonitorEnabled.name] as bool?,
      osuKeys: rawOsuKeys?.map((it) => int.parse(it)).toList(),
      beatmapsPath: keys[SettingsKey.beatmapsPath.name] as String?,
    );

    await setUpdate(loadedSettings);
    notify();
  }

  void _ensureInitialized() {
    if (_asyncPrefs == null) {
      const message =
          "SettingsRepository is not initialized. Call init() first";

      log(message, level: .error);
      throw Exception(message);
    }
  }

  Future<void> _writeAll(Settings data) async {
    final osuKeys = data.osuKeys.map((it) => it.toString()).toList();

    if (data.beatmapsPath != null) {
      await _asyncPrefs!.setString(
        SettingsKey.beatmapsPath.name,
        data.beatmapsPath!,
      );
    }
    await _asyncPrefs!.setInt(
      SettingsKey.audioCompensation.name,
      data.audioCompensation,
    );
    await _asyncPrefs!.setDouble(
      SettingsKey.globalVolume.name,
      data.globalVolume,
    );
    await _asyncPrefs!.setDouble(
      SettingsKey.musicVolume.name,
      data.musicVolume,
    );
    await _asyncPrefs!.setBool(
      SettingsKey.snakingSlidersEnabled.name,
      data.snakingSlidersEnabled,
    );
    await _asyncPrefs!.setBool(
      SettingsKey.parallaxEnabled.name,
      data.parallaxEnabled,
    );
    await _asyncPrefs!.setDouble(
      SettingsKey.backgroundDim.name,
      data.backgroundDim,
    );
    await _asyncPrefs!.setDouble(
      SettingsKey.backgroundBlur.name,
      data.backgroundBlur,
    );
    await _asyncPrefs!.setBool(
      SettingsKey.cursorTrailEnabled.name,
      data.cursorTrailEnabled,
    );
    await _asyncPrefs!.setBool(SettingsKey.logsEnabled.name, data.logsEnabled);
    await _asyncPrefs!.setBool(
      SettingsKey.fpsMonitorEnabled.name,
      data.fpsMonitorEnabled,
    );
    await _asyncPrefs!.setStringList(SettingsKey.osuKeys.name, osuKeys);
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => throw UnimplementedError(
    "SettingsRepositoryProvider needs to be overriden in ProviderScope",
  ),
);
