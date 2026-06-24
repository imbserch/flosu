import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flosu/models/storage/storage.dart';
import 'package:flosu/logic/services/storage.dart';
import 'package:flosu/logic/providers/router.dart';

/// Riverpod notifier that maintains the application's persistent settings.
///
/// Each setter method updates both the in-memory [Storage] state (triggering
/// a UI rebuild) and the underlying [StorageService] (which writes to
/// [SharedPreferences] asynchronously).
class StorageNotifier extends Notifier<Storage> {
  @override
  Storage build() {
    _service = ref.read(storageService);
    return _service.getInitialStorage();
  }

  late final StorageService _service;

  /// Opens a system folder picker and sets the beatmaps directory path.
  ///
  /// After the path is confirmed, the app navigates to the splash screen to
  /// trigger a full library reload.
  void setBeatmapsPath() async {
    final result = await FilePicker.getDirectoryPath(
      dialogTitle: "Select osu! songs folder",
      lockParentWindow: true,
    );

    if (result == null) return;

    // Update the provider state synchronously so the UI reacts immediately.
    state = state.copyWith(beatmapsPath: result);

    // Force a library reload by navigating through the splash screen.
    final context = rootNavigatorKey.currentContext!;
    if (context.mounted) context.go("/splash");

    // Persist the new path asynchronously.
    _service.setBeatmapsPath(result);
  }

  /// Clears the beatmaps directory path and reloads the library (empty).
  void clearBeatmapsPath() {
    state = state.copyWith(beatmapsPath: null, keepLastBeatmapsPath: false);

    final context = rootNavigatorKey.currentContext!;
    if (context.mounted) context.go("/splash");

    _service.setBeatmapsPath(null);
  }

  /// Sets the global audio timing compensation offset, clamped to ±200 ms.
  void setAudioCompensation(int compensation) {
    final compClamped = compensation.clamp(-200, 200);
    state = state.copyWith(audioCompensation: compClamped);
    _service.setAudioCompensation(compClamped);
  }

  /// Sets the master volume for all audio, clamped to [0.0, 1.0].
  void setGlobalVolume(double volume) {
    final volClamped = volume.clamp(0.0, 1.0);
    state = state.copyWith(globalVolume: volume);
    _service.setGlobalVolume(volClamped);
  }

  /// Sets the music track volume, clamped to [0.0, 1.0].
  void setMusicVolume(double volume) {
    final volClamped = volume.clamp(0.0, 1.0);
    state = state.copyWith(musicVolume: volume);
    _service.setMusicVolume(volClamped);
  }

  /// Sets the logical key code for the first gameplay key (K1).
  void setOsuK1(int keyId) {
    state = state.copyWith(osuK1: keyId);
    _service.setOsuK1(keyId);
  }

  /// Sets the logical key code for the second gameplay key (K2).
  void setOsuK2(int keyId) {
    state = state.copyWith(osuK2: keyId);
    _service.setOsuK2(keyId);
  }

  /// Enables or disables the snaking-slider animation.
  void setSnakingSliders(bool value) {
    state = state.copyWith(snakingSliders: value);
    _service.setSnakingSliders(value);
  }

  /// Enables or disables the background parallax effect.
  void setParallax(bool value) {
    state = state.copyWith(parallax: value);
    _service.setParallax(value);
  }

  /// Enables or disables the cursor trail effect.
  void setCursorTrail(bool value) {
    state = state.copyWith(showCursorTrail: value);
    _service.setCursorTrail(value);
  }

  /// Sets the background dim level, clamped to [0.0, 1.0].
  void setBackgroundDim(double value) {
    final dimClamped = value.clamp(0.0, 1.0);
    state = state.copyWith(backgroundDim: dimClamped);
    _service.setBackgroundDim(dimClamped);
  }

  /// Sets the background blur strength, clamped to [0.0, 1.0].
  void setBackgroundBlur(double value) {
    final blurClamped = value.clamp(0.0, 1.0);
    state = state.copyWith(backgroundBlur: blurClamped);
    _service.setBackgroundBlur(blurClamped);
  }
}

/// Global provider for [StorageNotifier].
final storageProvider = NotifierProvider(() => StorageNotifier());
