import 'dart:async';

import 'package:flosu/logic/services/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:flosu/logic/providers/storage.dart';
import 'package:flosu/logic/services/audio.dart';
import 'package:flosu/logic/services/storage.dart';
import 'package:flosu/models/beatmap/beatmap.dart';

typedef AudioTimingsCallback = void Function(Duration delay);

/// [AudioProvider] manages the application's audio playback state using Riverpod.
///
/// It maintains a cache of [AudioSource] objects to prevent redundant loading
/// and tracks the [SoundHandle] of the currently playing audio to handle
/// transitions and stops.
///
/// The state holds the [String] path of the currently active audio.
class AudioProvider extends Notifier<Beatmap?> {
  @override
  build() {
    //Get audio service
    _service = ref.read(audioService);
    _audioDelayTimer = Timer.periodic(
      Durations.long2,
      (_) => _checkAudioDelay(),
    );

    //Handle changes without rebuild this provider
    ref.listen(
      storageProvider.select((it) => it.audioCompensation),
      (_, offset) => _userOffset = Duration(milliseconds: offset),
      fireImmediately: true,
    );
    ref.listen(
      storageProvider.select((it) => it.globalVolume),
      (_, volume) => _service.setGlobalVolume(volume),
      fireImmediately: true,
    );
    ref.listen(storageProvider.select((it) => it.musicVolume), (_, volume) {
      _musicVolume = volume;
      if (_currentHandle != null) _service.setVolume(_currentHandle!, volume);
    }, fireImmediately: true);

    //Set dispose behavior (dispose service)
    ref.onDispose(() {
      _stopwatch.stop();
      _audioDelayTimer.cancel();

      if (_currentHandle != null) {
        _service.setStop(_currentHandle!);
      }
      _service.dispose();
      _logger.dispose();
    });

    return null;
  }

  // Notifier for updating audio logic as DT/NC mods
  final ValueNotifier<int> changedSources = ValueNotifier<int>(0);

  final ScopedLogger _logger = Logger.requestLogger("AudioProvider");

  /// The underlying service responsible for low-level audio operations.
  late final AudioService _service;

  late final Timer _audioDelayTimer;

  ///
  final List<AudioTimingsCallback> _delayHandlers = [];

  /// Cache of loaded audio sources indexed by their file path.
  final Map<String, AudioSource> _sources = {};

  /// High-precision timer used to interpolate audio position.
  ///
  /// Since the audio engine's reported position might have latency or
  /// jitter, this stopwatch provides a continuous microsecond-accurate
  /// reference for gameplay synchronization.
  final _stopwatch = Stopwatch();

  /// External compensation offset defined by the user in settings.
  /// This value is injected from [StorageService].
  Duration _userOffset = .zero;

  /// The starting time offset of the current audio instance.
  ///
  /// This represents the logical "zero" point of the track, such as the
  /// preview start time in menus. It is used to calculate the absolute
  /// position in [position].
  Duration _audioOffset = .zero;

  Duration _audioDuration = .zero;

  /// Reference to the path of the active audio instance currently playing.
  String? _currentPath;

  /// Reference to the active audio instance currently playing.
  SoundHandle? _currentHandle;

  /// The current speed multiplier of the audio playback.
  double _playbackRate = 1.0;

  /// If the service is playing audio
  bool _playing = false;

  double _musicVolume = 1.0;

  /// Checks audio delay and notifies it's listeners
  void _checkAudioDelay() async {
    if (_currentHandle == null) return;

    final servicePosition = _service.getPosition(_currentHandle!);
    final absolutePosition = position - _userOffset;

    final delay = (servicePosition - absolutePosition).abs();

    if (delay.inMilliseconds > 16) {
      _audioOffset = servicePosition;
      _stopwatch.reset();
      _logger.warn("Audio delay of ${delay.inMilliseconds} ms detected");
    }

    for (final handler in _delayHandlers) {
      handler(delay);
    }
  }

  void addTimingsHandler(AudioTimingsCallback handler) {
    _delayHandlers.add(handler);
  }

  void removeTimingsHandler(AudioTimingsCallback handler) {
    _delayHandlers.remove(handler);
  }

  /// Preloads an audio file into memory.
  ///
  /// Checks if the [path] is already in the [_sources] cache. If not, it
  /// requests the [_service] to load it.
  ///
  /// Returns the [AudioSource] if successful, otherwise returns `null`.
  Future<AudioSource?> load(Beatmap beatmap) async {
    final path = beatmap.audio.path;

    _logger.debug("Loading source: $path");

    // Check if the source is already cached to optimize performance
    if (_sources.containsKey(path)) {
      _logger.debug("Source is already loaded: $path");
      return _sources[path];
    }

    final source = await _service.load(path);

    if (source == null) {
      _logger.error("Source can't be loaded: $path");
      return null;
    }

    // Storage for future use to avoid re-decoding the same file
    _sources[path] = source;
    _logger.debug("Source loaded: $path");
    return source;
  }

  /// Plays an audio file from the beginning.
  ///
  /// If another audio is currently playing, it will be stopped using
  /// a medium duration fade-out to avoid "popping" sounds.
  ///
  /// [path]: The file location of the audio to be played.
  Future<void> play(Beatmap beatmap) async {
    final source = await load(beatmap);

    if (source == null) {
      _logger.error("Audio can't play: ${beatmap.audio.path}");
      return;
    }
    final handle = await _service.play(source, _musicVolume);

    if (handle == null) {
      _logger.error(
        "Audio can't start ${beatmap.audio.path}. Don't trying to stop last handle",
      );
      return;
    }

    _audioDuration = _service.getDuration(handle);

    // Set rate to match internal playbackRate
    _service.setRate(handle, _playbackRate);

    /// Disables looping and resets the offset for full track playback.
    _service.setClip(handle, null);
    _audioOffset = .zero;

    // Reset the internal clock immediately after playback starts
    // to minimize the delta between the engine and the CPU clock.
    _stopwatch
      ..start()
      ..reset();

    // Crossfade: Stop the previous audio if it exists
    if (_currentHandle != null) _service.setStop(_currentHandle!);

    _currentPath = beatmap.audio.path;
    _currentHandle = handle;
    _playing = true;
    state = beatmap;

    changedSources.value = changedSources.value + 1;
  }

  /// Previews an audio file with a volume fade-in effect.
  ///
  /// Useful for gallery or selection screens. It starts the audio at volume 0
  /// and fades it in, while simultaneously fading out and stopping the previous audio.
  ///
  /// [path]: The file location of the audio to preview.
  Future<void> preview(Beatmap beatmap, [bool force = false]) async {
    final offset = beatmap.audio.previewDuration;

    // Only set new beatmap and set audio clip behavior if audio is the currently playing handle
    if (_currentPath != null && _currentPath == beatmap.audio.path && !force) {
      state = beatmap;
      return _service.setClip(_currentHandle!, offset, false);
    }

    final source = await load(beatmap);

    if (source == null) {
      _logger.error(
        "Audio can't load: ${beatmap.audio.path}. No fading between handles",
      );
      return;
    }

    // Start playback at 0.0 volume to allow for a manual fade-in
    final handle = await _service.play(source, 0.0);

    if (handle == null) {
      _logger.error(
        "Audio can't preview ${beatmap.audio.path}. No fading between handles",
      );
      return;
    }

    _audioDuration = _service.getDuration(handle);

    // Set rate to match internal playbackRate
    _service.setRate(handle, _playbackRate);

    /// Enables looping at a specific point and sets the offset for
    /// correct position reporting.
    _service.setClip(handle, offset);
    _audioOffset = offset;

    // Synchronize the stopwatch with the start of the preview.
    _stopwatch
      ..start()
      ..reset();

    // Cross-fade: Fade out the previous handle before stopping it
    if (_currentHandle != null) {
      _service.setVolume(_currentHandle!, 0, Durations.medium1);
      _service.setStop(_currentHandle!, Durations.medium1);
    }

    // Fade in the new audio
    // Using updated osu!lazer fade logic
    Future.delayed(
      Durations.medium1 * 0.5,
      () => _service.setVolume(handle, _musicVolume, Durations.medium1),
    );

    _currentPath = beatmap.audio.path;
    _currentHandle = handle;
    _playing = true;
    state = beatmap;

    changedSources.value = changedSources.value + 1;
  }

  /// Updates the playback speed and resynchronizes the timing baseline.
  ///
  /// Changing the rate invalidates the current [Stopwatch] progression
  /// relative to the audio. To fix this, we capture the current position
  /// into [_audioOffset] before applying the new [rate] and resetting the clock.
  void setRate(double rate) {
    if (_currentHandle == null) {
      _logger.error("No handle to set playback rate");
      return;
    }
    // Capture the exact moment before the speed change
    _audioOffset = _service.getPosition(_currentHandle!);

    // Apply the new rate to the engine
    _playbackRate = _service.setRate(_currentHandle!, rate);

    _stopwatch.reset();
  }

  void setPitch(double pitch) {
    if (_currentHandle == null) {
      _logger.error("No handle to set pitch");
      return;
    }
    _service.setPitch(_currentHandle!, pitch);
  }

  /// Stops the current audio playback and clears the provider state.
  ///
  /// This method immediately halts the audio engine for the [_currentHandle]
  /// and resets the [state] to `null`, notifying listeners that no track
  /// is currently active.
  void stop() {
    if (_currentHandle == null) {
      _logger.error("No handles to stop");
      return;
    }

    // Immediate stop without fade
    _service.setStop(_currentHandle!);
    _audioDuration = .zero;

    // Clear synchronization data to prevent carry-over to the next track
    _stopwatch
      ..stop()
      ..reset();
    _audioOffset = .zero;

    // Invalidate the handle and update state to notify UI listeners
    _currentPath = null;
    _currentHandle = null;
    _playing = false;
    state = null;
  }

  /// Updates the playback state (play/pause) and synchronizes the timing system.
  ///
  /// When pausing, it captures the exact engine position into [_audioOffset]
  /// and resets the [_stopwatch]. When resuming, the [position] getter
  /// uses the captured offset as the new baseline.
  ///
  /// [playing]: True to resume playback, false to pause.
  void setPlaying(bool playing) {
    if (_currentHandle == null) {
      _logger.error("No handles to set play state");
      return;
    }

    // Tell the engine to pause or resume
    _service.setPlaying(_currentHandle!, playing);

    // Resynchronize the logical offset with the actual engine position.
    // This prevents the timing from drifting due to CPU/Audio clock mismatch.
    _audioOffset = _service.getPosition(_currentHandle!);

    // We stop and reset the stopwatch on pause because the position
    // is now fully captured within the _audioOffset.
    _playing = playing;

    if (playing) {
      _stopwatch.start();
    } else {
      _stopwatch
        ..stop()
        ..reset();
    }
  }

  Duration get duration {
    if (_currentHandle == null) return .zero;
    return _audioDuration;
  }

  /// Returns the current high-precision playback position,
  /// adjusted by the track's internal offset multiplied by the playback rate
  /// and the user's global offset.
  ///
  /// The formula ensures that visual sync accounts for hardware latency
  /// compensation: [_audioOffset] + [_stopwatch] * [_playbackRate] + [_userOffset].
  Duration get position {
    if (_currentHandle == null) return .zero;

    return _audioOffset + (_stopwatch.elapsed * _playbackRate) + _userOffset;
  }

  /// Same as [position], in milliseconds
  int get positionInMs => position.inMilliseconds;

  bool get playing {
    if (_currentHandle == null) return false;
    return _playing;
  }

  bool get completed {
    if (_currentHandle == null) return true;

    return position >= duration;
  }
}

/// Global provider for [AudioProvider].
final audioProvider = NotifierProvider<AudioProvider, Beatmap?>(
  () => AudioProvider(),
);
