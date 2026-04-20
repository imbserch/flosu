import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flosu/core/extensions.dart';
import 'package:flosu/models/storage/storage.dart';
import 'package:flosu/logic/services/storage.dart';
import 'package:flosu/logic/providers/router.dart';

class StorageNotifier extends Notifier<Storage> {
  @override
  Storage build() {
    _service = ref.read(storageService);
    return _service.getInitialStorage();
  }

  late final StorageService _service;

  void setBeatmapsPath() async {
    final result = await FilePicker.getDirectoryPath(
      dialogTitle: "Select osu! songs folder",
      lockParentWindow: true,
    );

    if (result == null) return;

    //Update provider state syncronously
    state = state.copyWith(beatmapsPath: result);

    //Force reload of beatmaps library
    "Beatmaps path updated. Refreshing...".log;
    final context = rootNavigatorKey.currentContext!;

    if (context.mounted) context.go("/splash");

    //Update internal state asyncronously
    _service.setBeatmapsPath(result);
  }

  void clearBeatmapsPath() {
    //Update provider state syncronously
    state = state.copyWith(beatmapsPath: null);

    //Force reload of beatmaps library
    "Beatmaps path removed. Refreshing...".log;
    final context = rootNavigatorKey.currentContext!;

    if (context.mounted) context.go("/splash");

    //Update internal state asyncronously
    _service.setBeatmapsPath(null);
  }

  void setAudioCompensation(int compensation) {
    final compClamped = compensation.clamp(-200, 200);

    //Update internal and service state
    state = state.copyWith(audioCompensation: compClamped);
    _service.setAudioCompensation(compClamped);
  }

  void setGlobalVolume(double volume) {
    final volClamped = volume.clamp(0.0, 1.0);

    //Update internal and service state
    state = state.copyWith(globalVolume: volume);
    _service.setGlobalVolume(volClamped);
  }

  void setMusicVolume(double volume) {
    final volClamped = volume.clamp(0.0, 1.0);

    //Update internal and service state
    state = state.copyWith(musicVolume: volume);
    _service.setMusicVolume(volClamped);
  }

  void setOsuK1(int keyId) {
    //Update internal and service state
    state = state.copyWith(osuK1: keyId);
    _service.setOsuK1(keyId);
  }

  void setOsuK2(int keyId) {
    //Update internal and service state
    state = state.copyWith(osuK2: keyId);
    _service.setOsuK2(keyId);
  }

  void setSnakingSliders(bool value) {
    //Update internal and service state
    state = state.copyWith(snakingSliders: value);
    _service.setSnakingSliders(value);
  }

  void setParallax(bool value) {
    //Update internal and service state
    state = state.copyWith(parallax: value);
    _service.setParallax(value);
  }

  void setCursorTrail(bool value) {
    //Update internal and service state
    state = state.copyWith(showCursorTrail: value);
    _service.setCursorTrail(value);
  }

  void setBackgroundDim(double value) {
    final dimClamped = value.clamp(0.0, 1.0);

    //Update internal and service state
    state = state.copyWith(backgroundDim: dimClamped);
    _service.setBackgroundDim(dimClamped);
  }

  void setBackgroundBlur(double value) {
    final blurClamped = value.clamp(0.0, 1.0);

    //Update internal and service state
    state = state.copyWith(backgroundBlur: blurClamped);
    _service.setBackgroundBlur(blurClamped);
  }
}

final storageProvider = NotifierProvider(() => StorageNotifier());
