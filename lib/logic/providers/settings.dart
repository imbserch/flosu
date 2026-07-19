import 'package:file_picker/file_picker.dart';
import 'package:flosu/models/repositories/settings.dart';
import 'package:flosu/repositories/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flosu/shared/navigation/router.dart';

/// The SettingsNotifier manages the application's persistent settings.
/// It also handles the navigation to the splash screen when the beatmaps path is set.
class SettingsNotifier extends Notifier<Settings> {
  late final SettingsRepository _repository = ref.read(
    settingsRepositoryProvider,
  );

  @override
  Settings build() {
    final subs = _repository.stream.listen((settings) => state = settings);

    ref.onDispose(subs.cancel);

    return _repository.cache ?? Settings();
  }

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

    _repository.set(.beatmapsPath, result);

    // Force a library reload by navigating through the splash screen.
    final context = rootNavigatorKey.currentContext!;
    if (context.mounted) context.go("/splash");
  }

  /// Clears the beatmaps directory path and reloads the library (empty).
  void clearBeatmapsPath() {
    _repository.set(.beatmapsPath, null);

    final context = rootNavigatorKey.currentContext!;
    if (context.mounted) context.go("/splash");
  }

  /// Sets the global audio timing compensation offset, clamped to ±200 ms.
  void setAudioCompensation(int compensation) {
    final compClamped = compensation.clamp(-200, 200);
    _repository.set(.audioCompensation, compClamped);
  }

  /// Sets the master volume for all audio, clamped to [0.0, 1.0].
  void setGlobalVolume(double volume) {
    final volClamped = volume.clamp(0.0, 1.0);
    _repository.set(.globalVolume, volClamped);
  }

  /// Sets the music track volume, clamped to [0.0, 1.0].
  void setMusicVolume(double volume) {
    final volClamped = volume.clamp(0.0, 1.0);
    _repository.set(.musicVolume, volClamped);
  }

  /// Sets the logical key code for the first gameplay key (K1).
  void setOsuK1(int keyId) {
    _repository.set(.osuKeys, ["$keyId", state.osuKeys[1]]);
  }

  /// Sets the logical key code for the second gameplay key (K2).
  void setOsuK2(int keyId) {
    _repository.set(.osuKeys, [state.osuKeys[0], "$keyId"]);
  }

  /// Enables or disables the snaking-slider animation.
  void setSnakingSliders(bool value) {
    _repository.set(.snakingSlidersEnabled, value);
  }

  /// Enables or disables the background parallax effect.
  void setParallax(bool value) => _repository.set(.parallaxEnabled, value);

  /// Enables or disables the cursor trail effect.
  void setCursorTrail(bool value) =>
      _repository.set(.cursorTrailEnabled, value);

  /// Sets the background dim level, clamped to [0.0, 1.0].
  void setBackgroundDim(double value) {
    final dimClamped = value.clamp(0.0, 1.0);
    _repository.set(.backgroundDim, dimClamped);
  }

  /// Sets the background blur strength, clamped to [0.0, 1.0].
  void setBackgroundBlur(double value) {
    final blurClamped = value.clamp(0.0, 1.0);
    _repository.set(.backgroundBlur, blurClamped);
  }

  /// Enables or disables the logs.
  void setShowLogs(bool value) {
    _repository.set(.logsEnabled, value);
  }

  /// Enables or disables the FPS monitor.
  void setShowFpsMonitor(bool value) {
    _repository.set(.fpsMonitorEnabled, value);
  }
}

/// Global provider for [SettingsNotifier].
final settingsProvider = NotifierProvider(() => SettingsNotifier());
