import 'package:collection/collection.dart';
import 'package:flosu/shared/logging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

/// [AudioService] acts as a low-level wrapper for the `flutter_soloud` engine.
///
/// Its primary responsibility is to abstract the audio backend and provide
/// a clean interface for loading, playing, and manipulating audio assets.
class AudioService with Logging {
  AudioService._();

  static final AudioService _instance = AudioService._();

  static AudioService get instance => _instance;

  /// Initializes the audio engine with a specific buffer size.
  ///
  /// The [bufferSize] is set to 128 to balance latency and performance.
  /// Any failure during initialization is logged and prevents playback.
  Future<void> init() async {
    try {
      requestLogger();

      await SoLoud.instance.init(bufferSize: 128);
      _soLoud = SoLoud.instance;

      _soLoud!.setMaxActiveVoiceCount(32);
      _soLoud!.filters.pitchShiftFilter.activate();

      log("AudioService has been initialized", level: .success);
    } catch (err) {
      log(
        "AudioService initialization error. $err\nAudio can't be played",
        level: .error,
      );

      removeLogger();
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
      final source = await _soLoud?.loadFile(path);

      // Ensure pitch shift filter is active for this source
      source?.filters.pitchShiftFilter.activate();

      return source;
    } catch (err) {
      log("Error loading file: $err", level: .error);
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
      log("Error playing file: $err", level: .error);
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

    if (duration != null) {
      log("Scheduling stop at $duration");
      return _soLoud?.scheduleStop(handle, duration);
    }
    log("Stopping sound");
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

      log("Setting loop point to $duration");
      _soLoud?.setLoopPoint(handle, duration);
    }
  }

  /// Sets the playback speed of a specific sound instance.
  ///
  /// [rate]: The speed multiplier. Clamped between 0.05x and 2.0x to
  /// prevent engine instability.
  /// [duration]: If provided, the speed will transition smoothly over
  /// this period.
  /// Returns the actual rate applied, or 1.0 if the engine is unavailable.
  double setRate(SoundHandle handle, double rate, [Duration? duration]) {
    final clampedRate = rate.clamp(0.05, 2.0);

    final source = _soLoud?.findAudioSourceByHandle(handle);

    if (source == null) {
      log("Can't find source for handle $handle", level: .error);
      return 1.0;
    }

    final filter = source.filters.pitchShiftFilter;

    if (duration != null) {
      //SoLoud doesn't support smooth transitions for now
      log("Setting rate to $rate");
      filter.timeStretch(handle, clampedRate);
      return rate;
    }

    log("Setting rate to $rate");
    filter.timeStretch(handle, clampedRate);
    return rate;
  }

  /// Pauses or resumes a specific sound instance.
  ///
  /// [playing]: true to resume (unpause), false to pause.
  void setPlaying(SoundHandle handle, bool playing) {
    log("Playing state changed to $playing");
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
      log("Fading volume to $clampedVol over $duration");

      _soLoud?.fadeVolume(handle, clampedVol, duration);
    } else {
      log("Setting volume to $clampedVol");
      _soLoud?.setVolume(handle, clampedVol);
    }
  }

  /// Updates the master volume level for all sounds managed by the engine.
  void setGlobalVolume(double volume) {
    log("Setting global volume to $volume");
    _soLoud?.setGlobalVolume(volume.clamp(0.0, 1.0));
  }

  void setPitch(SoundHandle handle, double pitch) {
    log("Setting pitch to $pitch");

    final source = _soLoud?.findAudioSourceByHandle(handle);

    if (source == null) {
      log("Can't find source for handle $handle", level: .error);
      return;
    }

    source.filters.pitchShiftFilter.shift(soundHandle: handle).value = pitch;
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
    removeLogger();
    _soLoud?.deinit();
  }
}

/// Global provider to access the [AudioService] singleton throughout the app.
final audioService = Provider<AudioService>((_) => AudioService.instance);
