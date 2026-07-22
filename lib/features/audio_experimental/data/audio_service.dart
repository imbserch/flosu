import 'dart:async';

import 'package:flosu/features/audio_experimental/domain/active_sound.dart';
import 'package:flosu/features/audio_experimental/domain/loaded_sound.dart';
import 'package:flosu/shared/logging.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

class ExperimentalAudioService with Logging {
  SoLoud? _soLoud;

  bool _initialized = false;

  final Map<AudioSource, StreamSubscription> _listenedSources = {};

  bool get isInitialized => _initialized;

  Timer? _stopTimer;

  double _lastRate = 1.0;
  double _lastPitch = 1.0;

  Future<void> init() async {
    // Prevent from reinitializing the service
    if (_initialized) return;

    try {
      requestLogger();

      _soLoud = SoLoud.instance;
      if (!_soLoud!.isInitialized) {
        await _soLoud!.init(bufferSize: 128);
        _soLoud!.setMaxActiveVoiceCount(32);
      }
      log("ExperimentalAudioService initialized", level: .success);
      _initialized = true;
    } catch (err) {
      log("ExperimentalAudioService init error: $err", level: .error);

      removeLogger();
    }
  }

  /// Loads the audio file, creates an AudioSource from it and returns the LoadedSound.
  Future<LoadedSound?> load(String path) async {
    _checkInitialized();

    try {
      final source = await _soLoud!.loadFile(path);
      source.filters.pitchShiftFilter.activate();

      return LoadedSound(this, source, path);
    } catch (err) {
      log("Error loading file: $err", level: .error);
      return null;
    }
  }

  /// Loads the audio asset, creates an AudioSource from it and returns the LoadedSound.
  Future<LoadedSound?> loadAsset(String path) async {
    _checkInitialized();

    try {
      final source = await _soLoud!.loadAsset(path);
      return LoadedSound(this, source, path);
    } catch (err) {
      log("Error loading asset: $err", level: .error);
      return null;
    }
  }

  /// Plays the given AudioSource. Returns the ActiveSound if successful, null otherwise.
  ActiveSound? play(
    LoadedSound sound, {
    bool paused = false,
    double? initialVolume,
  }) {
    _checkInitialized();

    try {
      final handle = _soLoud!.play(
        sound.source,
        paused: paused,
        volume: initialVolume ?? 1.0,
      );

      // Set rate and pitch from last time
      final activeSound = ActiveSound(
        this,
        handle,
        sound.source,
        sound.track,
      ).setRate(_lastRate).setPitch(_lastPitch);

      _listenSound(activeSound);

      return activeSound;
    } catch (err) {
      log("Error playing sound: $err", level: .error);
      return null;
    }
  }

  bool isValid(SoundHandle handle) {
    _checkInitialized();

    return _soLoud!.getIsValidVoiceHandle(handle);
  }

  double getRate(SoundHandle handle) {
    _checkInitialized();

    return _soLoud!.getRelativePlaySpeed(handle);
  }

  /// Protects the voice from being stopped by the voice allocator.
  void setProtect(SoundHandle handle, bool protect) {
    _checkInitialized();

    _soLoud!.setProtectVoice(handle, protect);
  }

  /// Stops and resets the given SoundHandle.
  ///
  /// This method is used by `stop` and `scheduleStop` to stop the sound
  /// and reset it to the beginning.
  ///
  /// Since SoLoud automatically removes the handle from the active sounds if
  /// `stop`/`scheduleStop` is called, it won't be possible to resume the sound
  /// after that.
  void _stop(SoundHandle handle) {
    setPlaying(handle, false);
    seek(handle, .zero);
  }

  /// Stops the given SoundHandle or schedules a stop at a specific time.
  void stop(SoundHandle handle, {Duration? after}) {
    _checkInitialized();

    setProtect(handle, false);

    if (after != null) {
      _stopTimer?.cancel();
      _stopTimer = Timer(after, () => _stop(handle));
      return;
    }

    _stop(handle);
  }

  /// Sets the volume of the specified `handle`. If `over` is specified,
  /// the volume will be set from the current volume to `at` over the
  /// specified `over` duration. Otherwise, it will be set immediately.
  void setVolume(SoundHandle handle, double at, {Duration? over}) {
    _checkInitialized();

    final clamped = at.clamp(0.0, 1.0);

    if (over != null) {
      _soLoud!.fadeVolume(handle, clamped, over);
    } else {
      _soLoud!.setVolume(handle, clamped);
    }
  }

  void setGlobalVolume(double volume) {
    _checkInitialized();

    _soLoud!.setGlobalVolume(volume.clamp(0.0, 1.0));
  }

  void setPlaying(SoundHandle handle, bool playing) {
    _checkInitialized();

    _soLoud!.setPause(handle, !playing);
  }

  void seek(SoundHandle handle, Duration to) {
    _checkInitialized();

    _soLoud!.seek(handle, to);
  }

  void setLooping(SoundHandle handle, bool looping, [Duration? loopPoint]) {
    _checkInitialized();

    _soLoud!.setLooping(handle, looping);
    if (looping && loopPoint != null) {
      _soLoud!.setLoopPoint(handle, loopPoint);
    }
  }

  Duration getPosition(SoundHandle handle) {
    _checkInitialized();

    return _soLoud!.getPosition(handle);
  }

  Duration getDuration(AudioSource source) {
    _checkInitialized();

    return _soLoud!.getLength(source);
  }

  void setRate(SoundHandle handle, double rate) {
    _checkInitialized();

    final clamped = rate.clamp(0.05, 2.0);
    final source = _soLoud!.findAudioSourceByHandle(handle);

    if (source != null) {
      source.filters.pitchShiftFilter.timeStretch(handle, clamped);
    }

    _lastRate = clamped;
  }

  void setPitch(SoundHandle handle, double pitch) {
    _checkInitialized();

    final source = _soLoud!.findAudioSourceByHandle(handle);

    if (source != null) {
      source.filters.pitchShiftFilter.shift(soundHandle: handle).value = pitch;
    }

    _lastPitch = pitch;
  }

  void disposeSound(ActiveSound source) {
    _checkInitialized();

    _cancelSoundListening(source);
  }

  void dispose() {
    if (!_initialized) return;

    removeLogger();

    _soLoud!.deinit();
    _soLoud = null;

    _initialized = false;
  }

  void _listenSound(ActiveSound sound) {
    _checkInitialized();

    final source = sound.source;
    final existingSubscription = _listenedSources[source];

    // Audio engine is already listening to this source, do not create another subscription
    if (existingSubscription != null) return;

    final subscription = sound.source.soundEvents.listen((e) {
      log("Audio source ${e.handle.id} event fired: ${e.event}");
    });

    final entry = <AudioSource, StreamSubscription>{source: subscription};

    _listenedSources.addEntries(entry.entries);
  }

  void _cancelSoundListening(ActiveSound sound) {
    final source = sound.source;
    final existingSubscription = _listenedSources[source];

    // If subscription doesn't exist, do nothing
    if (existingSubscription == null) return;

    existingSubscription.cancel();
    _listenedSources.remove(source);
  }

  void _checkInitialized() {
    final serviceInitialized = _initialized && _soLoud?.isInitialized == true;
    const message = "Audio service not initialized. Please call init() first.";

    assert(serviceInitialized, message);
    if (!serviceInitialized) throw StateError(message);
  }
}
