import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:flosu/core/extensions.dart';

/// [AudioService] acts as a low-level wrapper for the `flutter_soloud` engine.
///
/// Its primary responsibility is to abstract the audio backend and provide
/// a clean interface for loading, playing, and manipulating audio assets.
class AudioService {
  AudioService._();

  static final AudioService _instance = AudioService._();

  static AudioService get instance => _instance;

  /// Initializes the audio engine with a specific buffer size.
  ///
  /// The [bufferSize] is set to 256 to balance latency and performance.
  /// Any failure during initialization is logged and prevents playback.
  Future<void> init() async {
    try {
      await SoLoud.instance.init(bufferSize: 256);
      SoLoud.instance.setMaxActiveVoiceCount(64);
      _soLoud = SoLoud.instance;
    } catch (err) {
      "AudioService initialization error. $err\nAudio can't be played".log;
    }
  }

  /// Reference to the internal SoLoud engine instance.
  SoLoud? _soLoud;

  /// Loads an audio file into memory as an [AudioSource].
  ///
  /// [path] can be a local asset or file path. Returns `null` if the
  /// engine is not ready or the file fails to load.
  Future<AudioSource?> load(String path) async {
    try {
      return await _soLoud?.loadFile(path);
    } catch (err) {
      "Error loading file: $err".log;
      return null;
    }
  }

  /// Triggers the playback of a previously loaded [AudioSource].
  ///
  /// Returns a [SoundHandle], which is a unique identifier for this
  /// specific playback instance, allowing for real-time manipulation.
  Future<SoundHandle?> play(AudioSource source, [double volume = 1.0]) async {
    try {
      final handle = _soLoud?.play(source, volume: volume);

      // Protection is vital for background music or active gameplay tracks
      if (handle != null) _soLoud?.setProtectVoice(handle!, true);
      return handle;
    } catch (err) {
      "Error playing file: $err".log;
      return null;
    }
  }

  /// Stops a playing sound immediately or schedules it after a [duration].
  ///
  /// If [duration] is provided, it uses `scheduleStop` to halt the audio
  /// at a future point in time.
  void setStop(SoundHandle handle, [Duration? duration]) {
    // We must unprotect the voice so the engine can fully release it
    // and reuse the slot in the sound pool.
    _soLoud?.setProtectVoice(handle!, false);

    if (duration != null) return _soLoud?.scheduleStop(handle, duration);
    _soLoud?.stop(handle);
  }

  /// Configures looping behavior for a specific sound instance.
  ///
  /// If [duration] is provided, it enables looping and sets the point
  /// where the audio should restart.
  void setClip(SoundHandle handle, Duration? duration, [bool seek = true]) {
    _soLoud?.setLooping(handle, duration != null);

    if (duration != null) {
      if (seek) _soLoud?.seek(handle, duration);
      _soLoud?.setLoopPoint(handle, duration);
    }
  }

  /// Adjusts the playback speed of a specific sound instance.
  ///
  /// [rate]: The speed multiplier. Clamped between 0.05x and 2.0x to
  /// prevent engine instability.
  /// Returns the actual rate applied, or 1.0 if the engine is unavailable.
  double setRate(SoundHandle handle, double rate) {
    final clampedRate = rate.clamp(0.05, 2.0);

    _soLoud?.setRelativePlaySpeed(handle, clampedRate);
    return _soLoud != null ? clampedRate : 1.0;
  }

  /// Pauses or resumes a specific sound instance.
  ///
  /// [playing]: true to resume (unpause), false to pause.
  void setPlaying(SoundHandle handle, bool playing) {
    _soLoud?.setPause(handle, !playing);
  }

  /// Adjusts the volume of an active [SoundHandle].
  ///
  /// [volume]: Clamped between 0.0 (silent) and 1.0 (max).
  /// [duration]: If provided, the volume will transition smoothly (fade)
  /// over this period.
  void setVolume(SoundHandle handle, double volume, [Duration? duration]) {
    final clampedVol = volume.clamp(0.0, 1.0);

    if (duration != null) {
      _soLoud?.fadeVolume(handle, clampedVol, duration);
    } else {
      _soLoud?.setVolume(handle, clampedVol);
    }
  }

  /// Updates the master volume level for all sounds managed by the engine.
  void setGlobalVolume(double volume) {
    _soLoud?.setGlobalVolume(volume.clamp(0.0, 1.0));
  }

  /// Returns the current playback position of a specific sound instance
  /// directly from the audio engine.
  ///
  /// [handle]: The unique identifier for the active sound.
  /// Returns [Duration.zero] if the instance is no longer valid or
  /// the engine is not initialized.
  Duration getPosition(SoundHandle handle) {
    return _soLoud?.getPosition(handle) ?? .zero;
  }

  Duration getDuration(SoundHandle handle) {
    //Find sources in
    final source = _soLoud?.activeSounds.firstWhereOrNull(
      (a) => a.handles.any((h) => h == handle),
    );

    if (source == null) return Duration.zero;
    return _soLoud?.getLength(source) ?? Duration.zero;
  }

  void dispose() {
    _soLoud?.deinit();
  }
}

/// Global provider to access the [AudioService] singleton throughout the app.
final audioService = Provider<AudioService>((_) => AudioService.instance);
