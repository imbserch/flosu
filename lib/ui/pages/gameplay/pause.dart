import 'dart:async';

import 'package:flosu/core/mixins.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/logic/providers/audio.dart';
import 'package:flosu/logic/providers/gameplay_data.dart';
import 'package:flosu/shared/navigation/router.dart';
import 'package:flosu/models/inputs/inputs.dart';
import 'package:flosu/ui/shared/animatable_page.dart';
import 'package:flosu/ui/widgets/common/skewed_box.dart';
import 'package:flutter/material.dart' hide PointerEvent;
import 'package:go_router/go_router.dart';

class PausePage extends AnimatablePage {
  const PausePage({super.key, required super.uri});

  @override
  AnimatablePageState<PausePage> createState() => _PausePageState();
}

enum PauseExitAction { resume, reset, quit }

class _PausePageState extends AnimatablePageState<PausePage>
    with KeyboardEventHandler {
  /// How the pause screen is exiting.
  PauseExitAction _exitAction = PauseExitAction.resume;

  // Initialization
  @override
  void initState() {
    // Stop music
    ref.read(audioProvider.notifier).setPlaying(false);
    super.initState();
  }

  // Clean up
  @override
  void dispose() {
    final gameplay = globalRef.read(gameplayDataProvider.notifier);
    final audio = globalRef.read(audioProvider.notifier);

    switch (_exitAction) {
      case PauseExitAction.resume:
        audio.setPlaying(true);
        break;
      case PauseExitAction.quit:
        final beatmap = globalRef.read(audioProvider);
        if (beatmap != null) audio.preview(beatmap, true);
        Future.microtask(gameplay.clearReplay);
        break;
      case PauseExitAction.reset:
        // No-op (Replay can be replayed)
        break;
    }
    super.dispose();
  }

  @override
  Map<KeysState, VoidCallback> get keyHandlers => {
    // If escape key pressed, resume
    KeysState({.escape}): _resume,
    // If backslash key pressed, reset
    KeysState({.backslash}): _reset,
  };

  /// Navigates back to the gameplay page, resuming the game.
  void _resume() {
    _exitAction = PauseExitAction.resume;
    if (mounted) context.go("/gameplay");
  }

  void _reset() {
    _exitAction = PauseExitAction.reset;
    if (mounted) context.go("/load");
  }

  void _quit() {
    _exitAction = PauseExitAction.quit;
    if (mounted) context.go("/songs");
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
                  onTap: _resume,
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
                  onTap: _reset,
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
                  onTap: _quit,
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
