import 'dart:async';

import 'package:flosu/features/audio/data/audio_service.dart';
import 'package:flosu/features/audio/presentation/audio_provider.dart';
import 'package:flosu/features/settings/domain/settings_provider.dart';
import 'package:flosu/shared/logging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

class TrackNotifier extends Notifier<SoundHandle?> with Logging {
  late final AudioService _service;

  @override
  SoundHandle? build() {
    requestLogger();
    log("Initializing notifier...");

    _service = ref.read(audioProvider);

    ref.onDispose(removeLogger);

    log("Notifier initialized", level: .success);

    return null;
  }

  Future<void> loadTrack(String path) async => await _service.load(path);

  SoundHandle? playTrack(String path, {bool startPaused = false}) {
    if (!_service.isLoaded(path)) {
      if (!_service.isValidSource(path)) {
        final handle = _service.createSoundHandle(
          path,
          startPaused: startPaused,
          volume: ref.read(settingsProvider).musicVolume,
        );

        state = handle;
        return handle;
      }
      return null;
    }

    final handle = _service.createSoundHandle(
      path,
      startPaused: startPaused,
      volume: ref.read(settingsProvider).musicVolume,
    );

    state = handle;

    return handle;
  }

  void resume() {
    if (state == null) return;

    _service.setPlaying(state!);
  }

  void pause() {
    if (state == null) return;

    _service.setPlaying(state!, playing: false);
  }

  void volume(double volume, {Duration? over}) {
    if (state == null) return;

    _service.setVolume(state!, volume, over: over);
  }

  void setPitch(double pitch, {Duration? duration}) {
    if (state == null) return;

    _service.setPitch(state!, pitch, duration: duration);
  }

  void setRate(double rate, {Duration? duration}) {
    if (state == null) return;

    _service.setRate(state!, rate, duration: duration);
  }

  void seek(int position) {
    if (state == null) return;

    _service.seek(state!, position);
  }

  void loop({int? to}) {
    if (state == null) return;

    _service.loop(state!, to: to);
  }

  void stop({Duration? after}) {
    if (state == null) return;

    _service.stop(state!, after: after);
  }

  Duration get position {
    if (state == null) return .zero;

    return _service.getPosition(state!);
  }

  Duration get length {
    if (state == null) return .zero;

    return _service.getLength(state!);
  }

  bool get isValid => state != null ? _service.isValid(state!) : false;
}

final trackProvider = NotifierProvider(() => TrackNotifier());
