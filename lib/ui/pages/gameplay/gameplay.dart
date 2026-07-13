import 'dart:async';

import 'package:flosu/logic/providers/gameplay_data.dart';
import 'package:flosu/ui/widgets/gameplay/playfield.dart';
import 'package:flosu/ui/widgets/gameplay/replay_mouse_cursor.dart';
import 'package:flosu/ui/widgets/song_select/mod_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Slider, PointerEvent;
import 'package:flutter/services.dart' hide PointerEvent;
import 'package:go_router/go_router.dart';
import 'package:flosu/logic/providers/audio.dart';
import 'package:flosu/core/extensions/models.dart';
import 'package:flosu/models/inputs/inputs.dart';
import 'package:flosu/logic/providers/router.dart';
import 'package:flosu/ui/shared/animatable_page.dart';

class GameplayPage extends AnimatablePage {
  const GameplayPage({super.key, required super.uri});

  @override
  AnimatablePageState<GameplayPage> createState() => _GameplayPageState();
}

class _GameplayPageState extends AnimatablePageState<GameplayPage> {
  Timer? _resetHandlerTimer;

  // Flag to prevent multiple pause calls.
  // Initially set to true to prevent any input from being processed at first frame
  bool _handledPause = true;

  /// Tracks the set of logical keys held in the previous input event.
  /// Used to detect key-down transitions without repeats.
  Set<LogicalKeyboardKey> _lastKeys = {};

  @override
  void initState() {
    // Enable input handling after a short delay
    _resetHandler();

    ref.read(audioProvider.notifier).endedSources.addListener(_onAudioEnded);

    super.initState();
  }

  @override
  void dispose() {
    globalRef
        .read(audioProvider.notifier)
        .endedSources
        .removeListener(_onAudioEnded);

    _resetHandlerTimer?.cancel();

    super.dispose();
  }

  // The input handling will be managed by controller
  @override
  bool onInput(Set<LogicalKeyboardKey> keys, PointerEvent? pointer) {
    // Pointer-only events can arrive with the same key set — skip them.
    if (setEquals(_lastKeys, keys)) return false;

    bool handled = false;

    if (!_handledPause) {
      if (keys.changedAndPressed(LogicalKeyboardKey.escape, _lastKeys)) {
        _handledPause = true;
        handled = true;
        _pause();

        // Sometimes, user resumes gameplay while pause menu is leaving, so
        // we need to reset the handler after the animation ends
        _resetHandler();
      }
    }

    _lastKeys = keys.toSet();
    return handled;
  }

  void _onAudioEnded() {
    if (mounted) context.go("/scoring");
  }

  /// Navigates to the pause page, pausing the game.
  void _pause() {
    if (mounted) context.go("/gameplay/pause");
  }

  void _resetHandler() {
    _resetHandlerTimer?.cancel();
    _resetHandlerTimer = Timer(
      Durations.extralong4,
      () => _handledPause = false,
    );
  }

  @override
  Widget buildPage(BuildContext context, double animProgress) {
    // final controller = ref.watch(gameplayControllerProvider);
    // final audio = ref.read(audioProvider.notifier);
    final details = ref.watch(gameplayDataProvider);

    return Stack(
      fit: .expand,
      children: [
        Align(
          alignment: .topRight,
          child: Padding(
            padding: const .symmetric(vertical: 16, horizontal: 20),
            child: Row(
              mainAxisAlignment: .end,
              mainAxisSize: .min,
              children: [
                for (final mod in details.mods)
                  ModIcon.display(mod: mod, size: 24),
              ],
            ),
          ),
        ),

        Center(
          child: AspectRatio(
            aspectRatio: 512 / 388,
            child: FittedBox(
              fit: .contain,
              child: Container(
                margin: const .fromLTRB(0, 8, 0, 0),
                child: Container(
                  margin: .all(1.5 * details.metadata!.circleRadius),
                  height: 384,
                  width: 512,
                  child: Stack(
                    fit: .expand,
                    alignment: .center,
                    clipBehavior: .none,
                    children: [
                      const Playfield(),

                      // Use replay mouse cursor when watching a replay.
                      if (details.replay != null) const ReplayMouseCursor(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
