import 'package:flosu/features/audio_experimental/data/audio_service.dart';
import 'package:flosu/features/audio_experimental/domain/active_sound.dart';
import 'package:flosu/features/audio_experimental/domain/audio_track.dart';
import 'package:flosu/features/audio_experimental/domain/loaded_sound.dart';
import 'package:flosu/features/audio_experimental/presentation/audio_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Durations, ValueNotifier;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrackProvider extends Notifier<AudioTrack?> {
  // The service this provider belongs to
  late final ExperimentalAudioService _service;

  @override
  AudioTrack? build() {
    _service = ref.read(audioProvider);
    return null;
  }

  // All loaded audio sources
  final Map<AudioTrack, LoadedSound> _loadedSounds = {};

  // All active sounds
  final Map<AudioTrack, ActiveSound> _activeSounds = {};

  final ValueNotifier<ActiveSound?> _currentActiveSound = ValueNotifier(null);

  // The latest requested audio track to avoid race conditions
  AudioTrack? _latestRequestedTrack;

  /// The currently playing active sound.
  ActiveSound? get activeSound => _currentActiveSound.value;

  /// Loads an audio track.
  Future<void> loadTrack(AudioTrack track) async {
    _latestRequestedTrack = track;
    if (!_service.isInitialized) return;

    LoadedSound? sound = _loadedSounds[track];

    sound ??= await _service.load(track);

    if (sound == null) {
      throw Exception('Failed to load track');
    }

    _loadedSounds[track] = sound;
  }

  /// Plays a track, returning the active sound instance.
  /// If the track is already playing, it will return the existing active sound.
  ActiveSound? playTrack(AudioTrack track) =>
      _play(track)?.seek(.zero).setLooping();

  /// Plays a track in a loop, returning the active sound instance.
  /// If the track is already playing, it will return the existing active sound.
  ActiveSound? playLoopTrack(
    AudioTrack track, {
    required Duration loopPoint,
    bool seekToLoopPoint = true,
  }) {
    // Only append looping to the currently playing track,
    // to avoid mixing different tracks in the same active sound.
    final activeSound = _play(track, useFade: true)?.setLooping(to: loopPoint);

    if (seekToLoopPoint) activeSound?.seek(loopPoint);

    return activeSound;
  }

  ValueListenable<ActiveSound?> get activeSoundListenable =>
      _currentActiveSound;

  /// Changes the audio track.
  ActiveSound? _play(AudioTrack track, {bool useFade = false}) {
    // Used to get a new playable sound from the track when it's not valid.
    ActiveSound? getPlayable(AudioTrack track) => _loadedSounds[track]?.play();

    final fadeDuration = useFade ? Durations.medium4 : null;

    if (!_service.isInitialized) {
      throw StateError('Audio service is not initialized');
    }

    // If the currently active sound is the same as the one we want to play,
    // check if it's still valid. If it is, return it. Otherwise, resume it.
    if (_currentActiveSound.value?.track == track) {
      final current = _currentActiveSound.value!;

      return _setActiveSound(
        current.isValid
            ? current
            : getPlayable(current.track)!.volume(1, over: fadeDuration),
        useFade: useFade,
      );
    }

    final activeSound = _activeSounds[track];

    // If the track is already playing, return it. Otherwise, resume it.
    if (activeSound != null) {
      return _setActiveSound(
        activeSound.isValid
            ? activeSound
            : getPlayable(activeSound.track)!.volume(1, over: fadeDuration),
        useFade: useFade,
      );
    }

    if (_latestRequestedTrack != track) return _currentActiveSound.value;

    // If the track is not playing, play it. It will come with an fade-in effect.
    final newSound = _loadedSounds[track]
        ?.play(paused: true, initialVolume: 0)
        ?.resume()
        .volume(1, over: fadeDuration);

    if (newSound == null) {
      throw StateError(
        'Failed to play track. Measure you called loadTrack(track) before playing it.',
      );
    }

    return _setActiveSound(newSound, useFade: useFade);
  }

  /// Changes the audio track.
  ///
  /// [sound]: The sound to change to.
  /// [useFade]: Whether to use a fade effect.
  ActiveSound _setActiveSound(ActiveSound sound, {bool useFade = false}) {
    final fadeDuration = useFade ? Durations.short4 : null;

    if (_currentActiveSound.value?.track != sound.track) {
      // Stop the previous track, if any
      if (_currentActiveSound.value?.isValid ?? false) {
        _currentActiveSound.value!
            .volume(0, over: fadeDuration)
            .stop(after: fadeDuration);
      }
    }

    // Set new state
    _activeSounds[sound.track] = sound;
    _currentActiveSound.value = sound;
    state = sound.track;

    return sound;
  }
}

final trackProvider = NotifierProvider<TrackProvider, AudioTrack?>(
  () => TrackProvider(),
);
