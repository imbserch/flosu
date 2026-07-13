import 'dart:async';

import 'package:flosu/core/extensions/models.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/logic/providers/audio.dart';
import 'package:flosu/logic/providers/gameplay_data.dart';
import 'package:flosu/logic/providers/router.dart';
import 'package:flosu/models/inputs/inputs.dart';
import 'package:flosu/ui/shared/animatable_page.dart';
import 'package:flosu/ui/widgets/common/skewed_box.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide PointerEvent;
import 'package:flutter/services.dart' hide PointerEvent;
import 'package:go_router/go_router.dart';

class PausePage extends AnimatablePage {
  const PausePage({super.key, required super.uri});

  @override
  AnimatablePageState<PausePage> createState() => _PausePageState();
}

class _PausePageState extends AnimatablePageState<PausePage> {
  Timer? _resetHandlerTimer;

  // Flag to prevent multiple resume calls.
  // Initially set to true to prevent any input from being processed at first frame
  bool _handledResume = true;
  bool _exitToSongs = true;

  /// Tracks the set of logical keys held in the previous input event.
  /// Used to detect key-down transitions without repeats.
  Set<LogicalKeyboardKey> _lastKeys = {};

  // Initialization
  @override
  void initState() {
    // Enable input handling after a short delay
    _resetHandler();

    // Stop music
    ref.read(audioProvider.notifier).setPlaying(false);
    super.initState();
  }

  // Clean up
  @override
  void dispose() {
    final gameplay = globalRef.read(gameplayDataProvider.notifier);
    final audio = globalRef.read(audioProvider.notifier);

    // Set preview if going back to song list
    if (_exitToSongs) {
      final beatmap = globalRef.read(audioProvider);
      if (beatmap != null) audio.preview(beatmap, true);

      Future.microtask(gameplay.clearAll);
    } else {
      // Resume music if resumed
      audio.setPlaying(true);
    }

    _resetHandlerTimer?.cancel();
    super.dispose();
  }

  @override
  bool onInput(Set<LogicalKeyboardKey> keys, PointerEvent? pointer) {
    // Pointer-only events can arrive with the same key set — skip them.
    if (setEquals(_lastKeys, keys)) return false;

    bool handled = false;

    if (!_handledResume) {
      if (keys.changedAndPressed(LogicalKeyboardKey.escape, _lastKeys)) {
        handled = true;
        _resume();
      }
    }

    _lastKeys = keys.toSet();
    return handled;
  }

  /// Navigates back to the gameplay page, resuming the game.
  void _resume() {
    _handledResume = true;
    _exitToSongs = false;

    if (mounted) {
      setState(() {});
      context.go("/gameplay");
    }

    // Sometimes, user pauses gameplay while this screen is leaving, so
    // we need to reset the handler after the animation ends
    _resetHandler();
  }

  void _reset() {
    _handledResume = true;
    _exitToSongs = false;
    if (mounted) context.go("/load");

    // Sometimes, gameplay will end loading before this screen is leaving, so
    // we need to reset the handler after the animation ends
    _resetHandler();
  }

  void _quit() {
    _handledResume = true;
    _exitToSongs = true;
    if (mounted) context.go("/songs");

    // Sometimes, gameplay will end loading before this screen is leaving, so
    // we need to reset the handler after the animation ends
    _resetHandler();
  }

  void _resetHandler() {
    _resetHandlerTimer?.cancel();
    _resetHandlerTimer = Timer(Durations.extralong4, () {
      _handledResume = false;
      _exitToSongs = true;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget buildPage(BuildContext context, double t) {
    return Container(
      color: Colors.black.withAlpha(128),
      alignment: .center,
      child: Column(
        crossAxisAlignment: .center,
        mainAxisSize: .min,
        spacing: 12,
        children: [
          const Text(
            "paused",
            style: TextStyle(fontSize: 14, color: Colors.amber),
          ),
          Container(
            color: AppColors.containerHigh,
            padding: const .symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                SkewedBox(
                  onTap: _handledResume ? null : _resume,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    borderRadius: .zero,
                  ),
                  padding: const .all(8),
                  child: const Text(
                    "Resume",
                    textAlign: .center,
                    style: TextStyle(fontSize: 10, fontWeight: .bold),
                  ),
                ),
                SkewedBox(
                  onTap: _handledResume ? null : _reset,
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    borderRadius: .zero,
                  ),
                  padding: const .all(8),
                  child: const Text(
                    "Retry",
                    textAlign: .center,
                    style: TextStyle(fontSize: 10, fontWeight: .bold),
                  ),
                ),
                SkewedBox(
                  onTap: _handledResume ? null : _quit,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: .zero,
                  ),
                  padding: const .all(8),
                  child: const Text(
                    "Quit",
                    textAlign: .center,
                    style: TextStyle(fontSize: 10, fontWeight: .bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ) /* Align(
        alignment: .bottomCenter,
        child: Padding(
          padding: const .all(16),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .center,
            spacing: 8,
            children: [
              const Text("Gameplay paused", style: TextStyle(fontSize: 8)),
              Row(
                spacing: 8,
                mainAxisSize: .min,
                children: [
                  SkewedBox(
                    width: 80,
                    offset: Offset(0, 16 * (1 - t)),
                    onTap: _handledResume ? null : _resume,
                    decoration: const BoxDecoration(color: Colors.green),
                    padding: const .all(8),
                    child: const Text(
                      "Resume",
                      textAlign: .center,
                      style: TextStyle(fontSize: 10, fontWeight: .bold),
                    ),
                  ),
                  SkewedBox(
                    width: 80,
                    offset: Offset(0, -16 * (1 - t)),
                    onTap: _handledResume ? null : _reset,
                    decoration: BoxDecoration(color: Colors.amber.shade700),
                    padding: const .all(8),
                    child: const Text(
                      "Retry",
                      textAlign: .center,
                      style: TextStyle(fontSize: 10, fontWeight: .bold),
                    ),
                  ),
                  SkewedBox(
                    width: 80,
                    offset: Offset(0, 16 * (1 - t)),
                    onTap: _handledResume ? null : () => context.go("/songs"),
                    decoration: const BoxDecoration(color: Colors.red),
                    padding: const .all(8),
                    child: const Text(
                      "Go back",
                      textAlign: .center,
                      style: TextStyle(fontSize: 10, fontWeight: .bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ), */,
    );
  }
}
