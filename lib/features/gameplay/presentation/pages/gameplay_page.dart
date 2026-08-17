import 'dart:async';
import 'package:flosu/features/audio/audio.dart';
import 'package:flosu/shared/domain/beatmap/beatmap_selector.dart';
import 'package:flosu/shared/domain/mod/mod_selector.dart';
import 'package:flosu/shared/domain/replay/replay_selector.dart';
import 'package:flosu/shared/layout/main_layout_provider.dart';
import 'package:flosu/features/gameplay/presentation/widgets/playfield.dart';
import 'package:flosu/features/gameplay/presentation/widgets/replay_mouse_cursor.dart';
import 'package:flosu/features/song_select/presentation/widgets/mod_icon.dart';
import 'package:flosu/shared/input.dart';
import 'package:flutter/material.dart' hide Slider, PointerEvent;
import 'package:go_router/go_router.dart';
import 'package:flosu/shared/router.dart';
import 'package:flosu/shared/layout/animatable_page.dart';

class GameplayPage extends AnimatablePage {
  const GameplayPage({super.key, required super.uri});

  @override
  AnimatablePageState<GameplayPage> createState() => _GameplayPageState();
}

class _GameplayPageState extends AnimatablePageState<GameplayPage>
    with KeyboardHandler {
  @override
  void initState() {
    Future.microtask(() {
      // Lock top bar
      final layout = ref.read(mainLayoutProvider.notifier);
      layout.setTopBarLocked(true);
      layout.setDrawersLocked(true);
    });

    super.initState();
  }

  @override
  void dispose() {
    Future.microtask(() {
      final layout = globalRef.read(mainLayoutProvider.notifier);
      final topBarOpen = globalRef.read(mainLayoutProvider).isTopBarOpen;

      layout.setTopBarLocked(false);
      layout.setDrawersLocked(false);
      if (!topBarOpen) layout.toggleTopBar();
    });
    super.dispose();
  }

  @override
  bool input() {
    if (!keyboard.pressed) return false;

    switch (keyboard.key) {
      case .escape:
        _pause();
        return true;
      case .backslash:
        _retry();
        return true;
      default:
        return false;
    }
  }

  /* void _onAudioEnded() {
    if (mounted) context.go("/scoring");
  } */

  bool _pause() {
    final track = globalRef.read(trackProvider.notifier);
    track.pause();

    if (mounted) context.go("/gameplay/pause");

    return true;
  }

  bool _retry() {
    if (mounted) context.go("/load");
    return true;
  }

  @override
  Widget buildPage(BuildContext context) {
    final difficulty = ref.read(difficultyProvider);
    final replay = ref.read(replaySelector);
    final mods = ref.read(modSelector);

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
                for (final mod in mods) ModIcon.display(mod: mod, size: 24),
              ],
            ),
          ),
        ),

        // Back button (only for touch devices)
        /* Align(
          alignment: .bottomRight,
          child: Container(
            padding: const .all(8),
            margin: const .all(32),
            decoration: BoxDecoration(
              color: AppColors.container,
              shape: .circle,
            ),
            child: Icon(Icons.close, size: 12),
          ),
        ), */
        Center(
          child: AspectRatio(
            aspectRatio: 512 / 388,
            child: FittedBox(
              fit: .contain,
              child: Container(
                margin: const .fromLTRB(8, 16, 8, 0),
                child: Container(
                  margin: .all(difficulty.radius),
                  height: 384,
                  width: 512,
                  child: Stack(
                    fit: .expand,
                    alignment: .center,
                    clipBehavior: .none,
                    children: [
                      const Playfield(),

                      // Use replay mouse cursor when watching a replay.
                      if (replay != null) const ReplayMouseCursor(),
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
