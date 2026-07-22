import 'dart:async';
import 'package:flosu/features/gameplay/domain/gameplay_data.dart';
import 'package:flosu/logic/providers/main_layout.dart';
import 'package:flosu/features/gameplay/presentation/widgets/playfield.dart';
import 'package:flosu/features/gameplay/presentation/widgets/replay_mouse_cursor.dart';
import 'package:flosu/features/song_select/presentation/widgets/mod_icon.dart';
import 'package:flosu/shared/input.dart';
import 'package:flutter/material.dart' hide Slider, PointerEvent;
import 'package:go_router/go_router.dart';
import 'package:flosu/features/audio/data/audio_provider.dart';
import 'package:flosu/shared/router.dart';
import 'package:flosu/ui/shared/animatable_page.dart';

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

    ref.read(audioProvider.notifier).endedSources.addListener(_onAudioEnded);

    super.initState();
  }

  @override
  void dispose() {
    globalRef
        .read(audioProvider.notifier)
        .endedSources
        .removeListener(_onAudioEnded);

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

  void _onAudioEnded() {
    if (mounted) context.go("/scoring");
  }

  bool _pause() {
    ref.read(audioProvider.notifier).setPlaying(false);
    if (mounted) context.go("/gameplay/pause");
    return true;
  }

  bool _retry() {
    ref.read(audioProvider.notifier).setPlaying(true);
    if (mounted) context.go("/load");
    return true;
  }

  @override
  Widget buildPage(BuildContext context, double animProgress) {
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
                  margin: .all(1.5 * details.difficultyWithMods.circleRadius),
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
