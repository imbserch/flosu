import 'package:flosu/features/audio_experimental/data/audio_service.dart';
import 'package:flosu/features/audio_experimental/domain/active_sound.dart';
import 'package:flosu/features/audio_experimental/domain/audio_track.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

class LoadedSound {
  LoadedSound(this._service, this.source, this.track);

  final ExperimentalAudioService _service;
  final AudioSource source;
  final AudioTrack track;

  /// Plays the sound. Returns an ActiveSound if successful, null otherwise
  ActiveSound? play({bool paused = false, double? initialVolume}) =>
      _service.play(this, paused: paused, initialVolume: initialVolume);
}
