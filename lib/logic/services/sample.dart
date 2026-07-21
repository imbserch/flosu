import 'package:flosu/shared/logging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

/// A service that handles playback and management of audio sound effects.
///
/// It wraps the [SoLoud] audio engine to load, cache, play, pause, resume,
/// and dispose individual sound effect files.
//
class SampleService with Logging {
  SampleService._();

  static final SampleService _instance = SampleService._();
  static SampleService get instance => _instance;

  Future<void> init() async {
    requestLogger();

    //SoLoud has been initialized in AudioService, we just need to use the instance
    _soLoud = SoLoud.instance;
  }

  SoLoud? _soLoud;

  final Map<String, AudioSource> _sources = {};

  Future<void> load(String path) async {
    if (_sources.containsKey(path)) return;

    final sound = await _soLoud?.loadFile(path, mode: .memory);

    _sources[path] = sound!;

    log("Loaded sound: $path");
  }

  Future<void> loadFromAsset(String path) async {
    if (_sources.containsKey(path)) return;

    final sound = await _soLoud?.loadAsset(path);
    _sources[path] = sound!;

    log("Loaded sound from asset: $path");
  }

  Future<void> loadMultiple(List<String> paths) async {
    for (final path in paths) {
      await load(path);
    }
  }

  Future<void> loadMultipleFromAsset(List<String> paths) async {
    for (final path in paths) {
      await loadFromAsset(path);
    }
  }

  SoundHandle? play(String path, [double? volume]) {
    final sound = _sources[path];

    if (sound == null) {
      log("Sound not found: $path", level: .error);
      return null;
    }

    // TODO: Check if the sound is already playing on another handle, return the same handle

    final handle = _soLoud!.play(sound);

    log("Playing sound: $path using handle ${handle.id}");

    return handle;
  }

  void setLoop(SoundHandle handle, Duration? from) {
    _soLoud?.setLooping(handle, from != null);
    _soLoud?.setLoopPoint(handle, from ?? .zero);
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

    removeLogger();
  }
}

final sampleService = Provider((ref) {
  final instance = SampleService.instance;

  ref.onDispose(instance.dispose);
  return instance;
});
