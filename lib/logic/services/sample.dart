import 'package:flosu/core/assets.dart';
import 'package:flosu/logic/services/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

/// A service that handles playback and management of audio sound effects.
///
/// It wraps the [SoLoud] audio engine to load, cache, play, pause, resume,
/// and dispose individual sound effect files.
//
class SampleService {
  SampleService._();

  static final SampleService _instance = SampleService._();
  static SampleService get instance => _instance;

  final ScopedLogger _logger = Logger.requestLogger("SampleService");

  Future<void> init() async {
    //SoLoud has been initialized in AudioService, we just need to use the instance
    _soLoud = SoLoud.instance;

    List<String> neededSamplesAtStart = [
      AppSamples.uiCursorTap,
      AppSamples.uiSettingsPopIn,
      AppSamples.uiMenuClose,
      AppSamples.introWelcomeWelcomePiano,
    ];

    for (final path in neededSamplesAtStart) {
      await loadFromAsset(path);
      _logger.debug("Loaded sample at start: $path");
    }

    //Play intro sample after a short delay
    Future.delayed(
      Durations.long2,
      () => play(AppSamples.introWelcomeWelcomePiano),
    );
  }

  SoLoud? _soLoud;

  final Map<String, AudioSource> _sources = {};

  Future<void> load(String path) async {
    if (_sources.containsKey(path)) return;

    final sound = await _soLoud?.loadFile(path, mode: .memory);

    _sources[path] = sound!;

    _logger.debug("Loaded sound: $path");
  }

  Future<void> loadFromAsset(String path) async {
    if (_sources.containsKey(path)) return;

    final sound = await _soLoud?.loadAsset(path);
    _sources[path] = sound!;

    _logger.debug("Loaded sound from asset: $path");
  }

  SoundHandle? play(String path, [double? volume]) {
    final sound = _sources[path];

    if (sound == null) {
      _logger.error("Sound not found: $path");
      return null;
    }

    // TODO: Check if the sound is already playing on another handle, return the same handle

    final handle = _soLoud!.play(sound);

    _logger.debug("Playing sound: $path using handle ${handle.id}");

    return handle;
  }

  void pause(SoundHandle handle) => _soLoud?.setPause(handle, true);

  void resume(SoundHandle handle) => _soLoud?.setPause(handle, false);

  void stop(SoundHandle handle) => _soLoud?.stop(handle);

  void setVolume(SoundHandle handle, double volume) =>
      _soLoud?.setVolume(handle, volume);

  void seek(SoundHandle handle, Duration to) => _soLoud?.seek(handle, to);

  void dispose() {
    for (final sound in _sources.values) {
      _soLoud?.disposeSource(sound);
    }

    _logger.debug("Disposed all sounds");
  }
}

final sampleService = Provider((ref) {
  final instance = SampleService.instance;

  ref.onDispose(instance.dispose);
  return instance;
});
