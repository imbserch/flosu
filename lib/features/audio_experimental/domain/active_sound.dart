import 'package:flosu/features/audio_experimental/data/audio_service.dart';
import 'package:flosu/features/audio_experimental/domain/audio_track.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

class ActiveSound {
  ActiveSound(this._service, this.handle, this.source, this.track);

  final ExperimentalAudioService _service;
  final SoundHandle handle;
  final AudioSource source;
  final AudioTrack track;

  bool _wasStopped = false;

  ActiveSound volume(double at, {Duration? over}) {
    _service.setVolume(handle, at, over: over);
    return this;
  }

  ActiveSound stop({Duration? after}) {
    _service.stop(handle, after: after);
    _wasStopped = true;
    return this;
  }

  ActiveSound setProtect(bool protect) {
    _service.setProtect(handle, protect);
    return this;
  }

  ActiveSound seek(Duration to) {
    _service.seek(handle, to);
    return this;
  }

  ActiveSound setLooping({Duration? to}) {
    _service.setLooping(handle, to != null, to);
    return this;
  }

  ActiveSound setRate(double rate) {
    _service.setRate(handle, rate);
    return this;
  }

  ActiveSound setPitch(double pitch) {
    _service.setPitch(handle, pitch);
    return this;
  }

  ActiveSound resume() {
    _service.setPlaying(handle, true);
    _wasStopped = false;
    return this;
  }

  ActiveSound pause() {
    _service.setPlaying(handle, false);
    _wasStopped = false;
    return this;
  }

  bool get isValid => _service.isValid(handle) && !_wasStopped;

  double get rate => _service.getRate(handle);

  Duration get position => _service.getPosition(handle);

  Duration get duration => _service.getDuration(source);
}
