import 'package:flosu/logic/providers/beatmap.dart';
import 'package:flosu/ui/widgets/beatmap/beatmap_list.dart';
import 'package:flosu/ui/widgets/common/actions_bar.dart';
import 'package:flutter/material.dart' hide PointerEvent;
import 'package:flutter/services.dart' hide PointerEvent;
import 'package:go_router/go_router.dart';
import 'package:flosu/logic/providers/audio.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/core/extensions/models.dart';
import 'package:flosu/core/extensions/ui.dart';
import 'package:flosu/ui/shared/animatable_page.dart';
import 'package:flosu/ui/widgets/beatmap/current_beatmap_info.dart';
import 'package:flosu/ui/widgets/common/osu_logo.dart';
import 'package:flosu/ui/widgets/common/skewed_button_line.dart';

class SongSelectPage extends AnimatablePage {
  const SongSelectPage({super.key, required super.uri});

  @override
  AnimatablePageState<SongSelectPage> createState() => _SongSelectPageState();
}

class _SongSelectPageState extends AnimatablePageState<SongSelectPage> {
  @override
  bool get keyboardOnly => true;

  @override
  bool onInput(Set<LogicalKeyboardKey> keys, _) {
    bool handled = false;

    //If escape pressed, go back
    if (keys.pressed(.escape)) {
      if (mounted) context.go("/main");
      handled = true;
    }

    //If F1 pressed, open mods
    if (keys.pressed(LogicalKeyboardKey.f1)) {
      if (mounted) context.go("/songs/mods");
      handled = true;
    }

    //If F2 pressed, play random song
    if (keys.pressed(LogicalKeyboardKey.f2)) {
      _playRandom();
      handled = true;
    }

    //If F3 pressed, open replay window
    if (keys.pressed(LogicalKeyboardKey.f3)) {
      _pickReplay();
      handled = true;
    }

    return handled;
  }

  void _pickReplay() {
    if (mounted) context.go("/songs/pick-replay");
  }

  void _playRandom() async {
    final bm = ref.read(beatmapProvider.notifier).getRandom();
    if (bm != null) ref.read(audioProvider.notifier).preview(bm);
  }

  @override
  Widget buildPage(BuildContext context, double animProgress) {
    return Stack(
      alignment: .bottomCenter,
      children: [
        CurrentBeatmapInfo(animProgress: animProgress),

        Positioned(
          top: 0,
          left: context.screenScaled.width / 2,
          width: context.screenScaled.width / 2,
          height: context.screenScaled.height - 60,
          child: const Column(
            crossAxisAlignment: .end,
            children: [
              /*  SkewedBox(
                    constraints: const BoxConstraints(
                      minWidth: 280,
                      maxWidth: 448,
                    ),
                    width: context.screenScaled.width / 2,
                    offset: const Offset(20, 0),
                    padding: const .all(4),
                    decoration: BoxDecoration(
                      borderRadius: const .only(bottomLeft: .circular(8)),
                      color: Colors.grey.shade900.withAlpha(128),
                    ),
                    child: Column(
                      children: [
                        SkewedBox(
                          decoration: BoxDecoration(
                            borderRadius: .circular(2),
                            color: Colors.grey.shade800,
                          ),
                          margin: const .only(right: 22),
                          child: Row(
                            children: [
                              Expanded(
                                child: SkewedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: .circular(2),
                                    color: Colors.grey.shade900,
                                  ),
                                  child: TextField(
                                    controller: _sCon,
                                    onChanged: (_) {
                                      if (mounted) setState(() {});
                                    },
                                    style: const TextStyle(fontSize: 10),
              
                                    decoration: InputDecoration(
                                      isCollapsed: true,
                                      contentPadding: const .only(top: 6),
                                      constraints: const BoxConstraints(
                                        maxHeight: 30,
                                      ),
                                      helper: Transform.translate(
                                        offset: const Offset(0, -2),
                                        child: const Text(
                                          "0 matches",
                                          style: TextStyle(
                                            fontSize: 6,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ),
                                      hintText: "search...",
              
                                      hintStyle: const TextStyle(
                                        fontSize: 10,
                                      ),
              
                                      border: const OutlineInputBorder(
                                        borderSide: .none,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SkewedBox(
                                decoration: BoxDecoration(
                                  borderRadius: .circular(2),
                                ),
                                onTap: () {},
                                padding: const .fromLTRB(6, 8, 6, 8),
                                child: const Icon(Icons.search, size: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                   */
              // Beatmap list
              Expanded(child: BeatmapList()),
            ],
          ),
        ),

        ActionsBar(
          onBack: () => context.go("/main"),
          actionsPadding: const .only(left: 24),
          actionsSpacing: 4,
          actions: [
            SkewedButtonLine(
              offset: Offset(0, 48 * (1 - animProgress)),
              color: AppColors.green,
              icon: const Icon(Icons.auto_awesome),
              onTap: () => context.go("/songs/mods"),
              label: const Text("Mods"),
            ),
            SkewedButtonLine(
              offset: Offset(0, 72 * (1 - animProgress)),
              color: AppColors.lightBlue,
              icon: const Icon(Icons.shuffle),
              onTap: _playRandom,
              label: const Text("Random"),
            ),
            SkewedButtonLine(
              offset: Offset(0, 96 * (1 - animProgress)),
              color: AppColors.pink,
              icon: const Icon(Icons.file_open_outlined),
              onTap: _pickReplay,
              label: const Text("Open replay"),
            ),
            SkewedButtonLine(
              offset: Offset(0, 120 * (1 - animProgress)),
              color: AppColors.purple,
              icon: const Icon(Icons.settings_outlined),
              label: const Text("Options"),
            ),
            const Spacer(),
          ],
          trailing: Padding(
            padding: const .all(12),
            child: OsuLogo(
              scale: (1 / 5) * animProgress,
              onTap: () => context.go("/load"),
            ),
          ),
        ),
      ],
    );
  }
}
