import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

//TODO: REIMPLEMENT AND MOVE INTO LOGIC FOLDER, THIS IS A SERVICE, NOT A PROVIDER
class SampleService {
  final _instance = SoLoud.instance;

  final List<AudioHandle> _handles = [];

  Future<AudioHandle?> load(String path, double volume) async {
    if (_handles.any((a) => a.path == path)) return null;

    final sound = await _instance.loadFile(path, mode: .memory);
    final handle = _instance.play(sound, volume: volume, paused: true);

    final res = AudioHandle(path, handle, sound);
    _handles.add(res);
    return res;
  }

  void play(String path) async {
    final AudioHandle? handle = _handles.firstWhereOrNull(
      (a) => a.path == path,
    );

    if (handle == null) return;
    _instance.setPause(handle.handle, false);
  }

  Future<void> disposeAll() async {
    for (final handle in _handles) {
      await _instance.disposeSource(handle.source);
    }

    _handles.clear();
  }

  void pause(String path) async {
    final AudioHandle? handle = _handles.firstWhereOrNull(
      (a) => a.path == path,
    );

    if (handle == null) return;
    _instance.setPause(handle.handle, true);
  }

  void resume(String path) async {
    final AudioHandle? handle = _handles.firstWhereOrNull(
      (a) => a.path == path,
    );

    if (handle == null) return;
    _instance.setPause(handle.handle, false);
  }

  void dispose() => disposeAll();
}

final sampleService = Provider((ref) {
  final instance = SampleService();
  ref.onDispose(instance.dispose);
  return instance;
});

class AudioHandle {
  AudioHandle(this.path, this.handle, this.source);

  final String path;
  final SoundHandle handle;
  final AudioSource source;
}
