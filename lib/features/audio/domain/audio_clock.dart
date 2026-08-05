import 'dart:math' hide log;

import 'package:flosu/core/constants.dart';
import 'package:flosu/core/engine/game_loop.dart';
import 'package:flosu/features/audio/presentation/audio_provider.dart';
import 'package:flosu/features/audio/presentation/track_provider.dart';
import 'package:flosu/shared/logging.dart';
import 'package:flosu/features/audio/data/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

import '../../settings/domain/settings_provider.dart';

class AudioClock extends Notifier<double> with Logging {
  late final AudioService _service;

  SoundHandle? _handle;

  double _internalTime = 0;
  int _audioOffset = 0;

  double _delay = 0.0;
  double get clockDelay => _delay;

  @override
  double build() {
    requestLogger();

    _service = ref.read(audioProvider);

    ref.listen(trackProvider, _listenHandle, fireImmediately: true);

    GameLoop.subscribe(_process);

    ref.listen(
      settingsProvider.select((it) => it.audioCompensation),
      (_, offset) => _audioOffset = offset,
      fireImmediately: true,
    );

    ref.onDispose(() {
      GameLoop.unsubscribe(_process);
      removeLogger();
    });

    return 0.0;
  }

  void _listenHandle(_, SoundHandle? newHandle) {
    _handle = newHandle;

    final position = newHandle != null
        ? _service.getPosition(newHandle)
        : Duration.zero;

    final initialPos = position.inMicroseconds / 1000.0;
    _internalTime = initialPos;

    state = initialPos + _audioOffset + AUDIO_BASE_COMPENSATION;
  }

  void _process(double delta) {
    if (_handle == null) {
      if (state != 0) state = 0;
      return;
    }

    // Audio time must not be changed while handle is invalid
    if (!_service.isValid(_handle!)) return;

    // Don't change time if audio isn't playing
    if (!_service.isPlaying(_handle!)) return;

    double time = _internalTime + (delta * _service.getRate(_handle!));

    final audioTime = _service.getPosition(_handle!).inMicroseconds / 1000.0;

    final drift = audioTime - time;
    _delay = drift.abs();

    switch (_delay) {
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

    _internalTime = time;
    state = time + _audioOffset + AUDIO_BASE_COMPENSATION;
  }
}

final audioClock = NotifierProvider(() => AudioClock());
