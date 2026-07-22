import 'dart:async';

import 'package:flosu/features/audio_experimental/audio.dart';
import 'package:flosu/models/generated/beatmap_metadata.dart';
import 'package:flosu/shared/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:flosu/features/settings/domain/settings.dart';
import 'package:flosu/features/audio/data/audio_service.dart';

typedef AudioTimingsCallback = void Function(Duration delay);

/// [AudioProvider] manages the application's audio playback state using Riverpod.
///
/// It maintains a cache of [AudioSource] objects to prevent redundant loading
/// and tracks the [SoundHandle] of the currently playing audio to handle
/// transitions and stops.
///
/// The state holds the [String] path of the currently active audio.
class AudioProvider extends Notifier<BeatmapMetadata?> with Logging {
  @override
  build() {
    requestLogger();

    //Get audio service
    _service = ref.read(audioService);
    _audioDelayTimer = Timer.periodic(
      Durations.short4,
      (_) => _checkAudioDelay(),
    );

    //Handle changes without rebuild this provider
    ref.listen(
      settingsProvider.select((it) => it.audioCompensation),
      (_, offset) => _userOffset = Duration(milliseconds: offset),
      fireImmediately: true,
    );
    ref.listen(
      settingsProvider.select((it) => it.globalVolume),
      (_, volume) => _service.setGlobalVolume(volume),
      fireImmediately: true,
    );
    ref.listen(settingsProvider.select((it) => it.musicVolume), (_, volume) {
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
      removeLogger();
    });

    return null;
  }

  // Notifier for updating audio logic as DT/NC mods
  final ValueNotifier<int> changedSources = ValueNotifier<int>(0);

  // Notifier for listening audio finalizations
  final ValueNotifier<int> endedSources = ValueNotifier<int>(-1);

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

  Duration _previousOffset = .zero;

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

    if (absolutePosition > _previousOffset) {
      if (servicePosition == .zero) {
        endedSources.value = _currentHandle?.id ?? -1;
        _stopwatch
          ..reset()
          ..stop();
      }
    }

    if (delay.inMilliseconds > 16) {
      _audioOffset = servicePosition;
      _stopwatch.reset();
      log(
        "Audio delay of ${delay.inMilliseconds} ms detected",
        level: .warning,
      );
    }

    _previousOffset = absolutePosition;

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
  ///
  /// NOTE: This provider doesn't manage the audio sources anymore. Use
  /// [TrackProvider] instead.
  Future<AudioSource?> load(BeatmapMetadata beatmap) async {
    final audioPath = beatmap.general.audioPath;

    if (audioPath == null) return null;

    await ref.read(trackProvider.notifier).loadTrack(audioPath);
    return null;
  }

  /// Plays an audio from beatmap from the beginning.
  ///
  /// If another audio is currently playing, it will be stopped.
  ///
  /// NOTE: This provider doesn't manage the audio sources anymore. Use
  /// [TrackProvider] instead.
  Future<void> play(BeatmapMetadata beatmap) async {
    final audioPath = beatmap.general.audioPath;

    if (audioPath == null) return;

    ref.read(trackProvider.notifier).playTrack(audioPath);
    state = beatmap;
  }

  /// Previews an audio from beatmap with a volume fade-in effect.
  ///
  /// Useful for gallery or selection screens. It starts the audio at volume 0
  /// and fades it in, while simultaneously fading out and stopping the previous audio.
  ///
  /// NOTE: This provider doesn't manage the audio sources anymore. Use
  /// [TrackProvider] instead.
  Future<void> preview(BeatmapMetadata beatmap, [bool force = false]) async {
    final audioPath = beatmap.general.audioPath;
    final previewTime = Duration(milliseconds: beatmap.general.previewTime);

    if (audioPath == null) return;

    ref
        .read(trackProvider.notifier)
        .playLoopTrack(
          audioPath,
          loopPoint: previewTime,
          seekToLoopPoint: force,
        );
    state = beatmap;
  }

  /// Updates the playback speed and resynchronizes the timing baseline.
  ///
  /// Changing the rate invalidates the current [Stopwatch] progression
  /// relative to the audio. To fix this, we capture the current position
  /// into [_audioOffset] before applying the new [rate] and resetting the clock.
  void setRate(double rate) {}

  /// NOTE: This provider doesn't manage the audio sources anymore. Use
  /// [TrackProvider] instead.
  void setPitch(double pitch) {}

  /// Stops the current audio playback and clears the provider state.
  ///
  /// This method immediately halts the audio engine for the [_currentHandle]
  /// and resets the [state] to `null`, notifying listeners that no track
  /// is currently active.
  ///
  /// NOTE: This provider doesn't manage the audio sources anymore. Use
  /// [TrackProvider] instead.
  void stop() {}

  /// Updates the playback state (play/pause) and synchronizes the timing system.
  ///
  /// When pausing, it captures the exact engine position into [_audioOffset]
  /// and resets the [_stopwatch]. When resuming, the [position] getter
  /// uses the captured offset as the new baseline.
  ///
  /// [playing]: True to resume playback, false to pause.
  ///
  /// NOTE: This provider doesn't manage the audio sources anymore. Use
  /// [TrackProvider] instead.
  void setPlaying(bool playing) {}

  void seek(Duration to) {
    // No-op for now
  }

  /// NOTE: This provider doesn't manage the audio sources anymore. Use
  /// [TrackProvider] instead.
  Duration get duration => Durations.extralong4;

  /// Returns the current high-precision playback position,
  /// adjusted by the track's internal offset multiplied by the playback rate
  /// and the user's global offset.
  ///
  /// The formula ensures that visual sync accounts for hardware latency
  /// compensation: [_audioOffset] + [_stopwatch] * [_playbackRate] + [_userOffset].
  ///
  /// NOTE: This provider doesn't manage the audio sources anymore. Use
  /// [TrackProvider] instead.
  Duration get position => .zero;

  /// Same as [position], in milliseconds
  ///
  /// NOTE: This provider doesn't manage the audio sources anymore. Use
  /// [TrackProvider] instead.
  int get positionInMs => 0;

  /// NOTE: This provider doesn't manage the audio sources anymore. Use
  /// [TrackProvider] instead.
  bool get playing => false;

  /// NOTE: This provider doesn't manage the audio sources anymore. Use
  /// [TrackProvider] instead.
  bool get completed => false;
}

/// Global provider for [AudioProvider].
final audioProvider = NotifierProvider<AudioProvider, BeatmapMetadata?>(
  () => AudioProvider(),
);
