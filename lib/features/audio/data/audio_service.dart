import 'dart:async';
import 'dart:math' show max;

import 'package:flosu/core/constants.dart';
import 'package:flosu/features/audio/domain/audio_track.dart';
import 'package:flosu/shared/logging.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

class AudioTrackException implements Exception {
  AudioTrackException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AudioService with Logging {
  SoLoud? _soLoud;
  bool _initialized = false;

  final Map<String, AudioTrack> _tracks = {};
  final Map<String, Completer<bool>> _completers = {};

  int get tracks => _tracks.entries.where((e) => e.value.source != null).length;
  int get loadingTracks =>
      _completers.entries.where((e) => !e.value.isCompleted).length;

  Future<void> init() async {
    // Prevent from reinitializing the service
    if (_initialized) return;

    try {
      requestLogger();

      _soLoud = SoLoud.instance;

      if (!_soLoud!.isInitialized) {
        log("Initializing service (SoLoud)...");
        await _soLoud!.init(
          sampleRate: AUDIO_SAMPLE_RATE,
          bufferSize: AUDIO_BUFFER_SIZE,
        );
        _soLoud!.setMaxActiveVoiceCount(256);
      }

      log("Service (SoLoud) initialized", level: .success);
      _initialized = true;
    } catch (err) {
      log("Service (SoLoud) init error: $err", level: .error);

      removeLogger();
    }
  }

  void dispose() {
    if (!_initialized) return;

    removeLogger();

    _completers.forEach((_, comp) => comp.complete(false));

    _soLoud!.deinit();
    _soLoud = null;

    _initialized = false;
  }

  bool isLoaded(String path) => _completers[path]?.isCompleted ?? false;

  AudioTrack _getTrack(String path) {
    return _tracks.putIfAbsent(path, () => AudioTrack(path: path));
  }

  Future<void> load(String path, {loadInMemory = false}) async {
    final name = getNameForPath(path, includeParent: true);
    log("Loading track: $name", level: .info);

    // If the track is already loaded, do nothing.
    if (isLoaded(path)) return;

    final completer = _completers[path];

    if (completer != null) {
      if (completer.isCompleted) return;

      log("Waiting track to load: $name", level: .info);
      await completer.future;
      return;
    }

    log("Loading track: $name");
    final track = _getTrack(path);

    final loadCompleter = Completer<bool>();
    _completers[path] = loadCompleter;

    try {
      track.source = await _soLoud!.loadFile(
        path,
        mode: loadInMemory ? .memory : .disk,
      );
      track.source?.filters.pitchShiftFilter.activate();

      log("Track loaded: $name", level: .success);

      loadCompleter.complete(true);
    } catch (e) {
      // Ensure completer is not called
      _completers.remove(path);
      loadCompleter.complete(false);
    }
  }

  SoundHandle createSoundHandle(
    String path, {
    bool startPaused = true,
    double volume = 1.0,
  }) {
    final name = getNameForPath(path, includeParent: true);
    final track = _tracks[path];

    final isLoaded = _completers[path]?.isCompleted ?? false;

    if (track == null || track.source == null || !isLoaded) {
      throw AudioTrackException("Track not loaded: $name");
    }

    log("Playing track: $name", level: .info);
    final handle = _soLoud!.play(track.source!, paused: true, volume: volume);
    if (!startPaused) _soLoud!.setPause(handle, false);

    _soLoud!.setInaudibleBehavior(handle, true, false);

    return handle;
  }

  void setPlaying(SoundHandle handle, {bool playing = true}) {
    _soLoud!.setPause(handle, !playing);
  }

  void setGlobalVolume(double volume, {Duration? over}) {
    if (over != null) {
      return _soLoud?.fadeGlobalVolume(volume, over);
    }

    _soLoud?.setGlobalVolume(volume);
  }

  void setVolume(SoundHandle handle, double volume, {Duration? over}) {
    if (over != null) {
      return _soLoud?.fadeVolume(handle, volume, over);
    }

    _soLoud?.setVolume(handle, volume);
  }

  void setPitch(SoundHandle handle, double pitch, {Duration? duration}) {
    final source = _soLoud!.findAudioSourceByHandle(handle);

    if (source != null) {
      final shift = source.filters.pitchShiftFilter.shift(soundHandle: handle);

      if (duration != null) {
        return shift.fadeFilterParameter(to: pitch, time: duration);
      }

      shift.value = pitch;
    }
  }

  void setRate(SoundHandle handle, double rate, {Duration? duration}) async {
    final source = _soLoud!.findAudioSourceByHandle(handle);

    if (source != null) {
      final filter = source.filters.pitchShiftFilter;

      if (duration != null) {
        // ignore: constant_identifier_names
        const SLEEP_DURATION = 50;

        final currentRate = _soLoud!.getRelativePlaySpeed(handle);

        final steps = duration.inMilliseconds / SLEEP_DURATION;
        final stepRate = (rate - currentRate) / steps;

        for (int i = 1; i <= steps; i++) {
          filter.timeStretch(handle, currentRate + stepRate * i);
          await Future.delayed(const Duration(milliseconds: SLEEP_DURATION));
        }

        return;
      }

      filter.timeStretch(handle, rate);
    }
  }

  void seek(SoundHandle handle, int position) {
    _soLoud!.seek(handle, Duration(milliseconds: position));
  }

  void loop(SoundHandle handle, {int? to}) {
    _soLoud!.setLooping(handle, to != null);
    if (to != null) {
      _soLoud!.setLoopPoint(handle, Duration(milliseconds: to));
    }
  }

  void stop(SoundHandle handle, {Duration? after}) {
    if (after != null) {
      return _soLoud!.schedulePause(handle, after);
    }

    _soLoud!.stop(handle);
  }

  Duration getPosition(SoundHandle handle) {
    return _soLoud!.getPosition(handle);
  }

  Duration getLength(SoundHandle handle) {
    final source = _soLoud!.findAudioSourceByHandle(handle);
    return _soLoud!.getLength(source!);
  }

  bool isValid(SoundHandle handle) => _soLoud!.getIsValidVoiceHandle(handle);

  bool isValidSource(String path) => _tracks[path]?.source != null
      ? _soLoud!.getIsValidVoiceHandle(_tracks[path]!.source!.handles.last)
      : false;

  bool isPlaying(SoundHandle handle) =>
      isValid(handle) ? !_soLoud!.getPause(handle) : false;

  double getRate(SoundHandle handle) => _soLoud!.getRelativePlaySpeed(handle);

  double getPitch(SoundHandle handle) {
    final source = _soLoud!.findAudioSourceByHandle(handle);
    return source!.filters.pitchShiftFilter.shift(soundHandle: handle).value;
  }

  List<String> _getSegments(String path) => path.split(RegExp(r'[/\\]'));

  String getNameForPath(String path, {bool includeParent = true}) {
    final segments = _getSegments(path);
    return segments
        .getRange(
          max(0, segments.length - (includeParent ? 2 : 1)),
          segments.length,
        )
        .join("/");
  }
}
