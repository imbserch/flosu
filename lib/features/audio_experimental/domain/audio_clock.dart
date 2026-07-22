import 'dart:math' hide log;

import 'package:flosu/core/engine/game_loop.dart';
import 'package:flosu/features/audio_experimental/audio.dart';
import 'package:flosu/shared/logging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioClock extends Notifier<double> with Logging {
  ActiveSound? _activeSound;

  @override
  double build() {
    requestLogger();

    final activeSound = ref.read(trackProvider.notifier).activeSoundListenable;

    _setAudio();
    activeSound.addListener(_setAudio);
    GameLoop.subscribe(_process);

    ref.onDispose(() {
      GameLoop.unsubscribe(_process);
      activeSound.removeListener(_setAudio);
      removeLogger();
    });

    return 0.0;
  }

  void _process(double delta) {
    if (_activeSound == null) {
      if (state != 0) state = 0;
      return;
    }

    // Audio time must not be changed while handle is invalid
    if (!_activeSound!.isValid) return;

    double time = state + (delta * _activeSound!.rate);

    final audioTime = _activeSound!.position.inMicroseconds / 1000.0;

    final drift = audioTime - time;
    final absDrift = drift.abs();

    switch (absDrift) {
      // If the drift is 240ms or more, we need to reset the audio time
      // because it's way out of sync.
      case >= 240:
        time = audioTime;
        log("Resetting time to $time", level: .warning);
        break;
      // If the drift is 16ms or more, we need to correct the audio time
      // using a lerp to smooth the transition.
      case >= 16:
        const k = 10.0;
        final factor = 1.0 - exp(-k * (delta / 1000.0));

        final step = drift * factor;

        time += step;
        log("Interpolating time by $step");
        break;
      // If the drift is less than 16ms, we don't need to correct the audio time
      default:
        break;
    }

    state = time;
  }

  void _setAudio() {
    log("Setting time from source");

    _activeSound = ref.read(trackProvider.notifier).activeSoundListenable.value;
    state = (_activeSound?.position.inMicroseconds ?? 0) / 1000.0;
  }
}

final audioClockProvider = NotifierProvider(() => AudioClock());
