import 'package:flosu/core/constants.dart';
import 'package:flosu/core/extensions/models.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/logic/providers/beatmap.dart';
import 'package:flosu/ui/shared/animatable_page.dart';
import 'package:flosu/ui/widgets/common/actions_bar.dart';
import 'package:flosu/ui/widgets/common/osu_button.dart';
import 'package:flosu/ui/widgets/common/skewed_box.dart';
import 'package:flosu/ui/widgets/common/top_banner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class ReplayPickerPage extends AnimatablePage {
  const ReplayPickerPage({super.key, required super.uri});

  @override
  AnimatablePageState<ReplayPickerPage> createState() =>
      _ReplayPickerPageState();
}

class _ReplayPickerPageState extends AnimatablePageState<ReplayPickerPage> {
  @override
  bool get keyboardOnly => true;

  @override
  bool onInput(Set<LogicalKeyboardKey> keys, _) {
    bool handled = false;

    //If escape pressed, go back
    if (keys.pressed(.escape)) {
      if (mounted) context.go("/songs");
      handled = true;
    }

    return handled;
  }

  @override
  Widget buildPage(BuildContext context, double t) {
    final path = ["C:", "Users", "default", "AppData", "Local"];

    return Material(
      color: Colors.black38,
      child: Stack(
        alignment: .bottomCenter,
        children: [
          //Mods container
          Column(
            children: [
              const TopBanner(
                title: "Replay selection",
                description:
                    "Select a replay to watch. Replays are recorded plays of the game "
                    "and can be used to learn from other players or to just watch "
                    "fun plays.",
              ),
              // Hidden until implementation
              if (kDebugMode)
                Expanded(
                  child: Padding(
                    padding: const .fromLTRB(24, 0, 24, 32),
                    child: Column(
                      mainAxisAlignment: .center,
                      crossAxisAlignment: .center,
                      mainAxisSize: .min,
                      spacing: 4,
                      children: [
                        SizedBox(
                          height: 16,
                          child: ScrollConfiguration(
                            behavior: defaultScrollBehavior,
                            child: ListView.separated(
                              itemCount: path.length,
                              scrollDirection: .horizontal,
                              itemBuilder: (_, idx) => OsuButton(
                                borderRadius: .circular(2),
                                color: AppColors.middle(
                                  AppColors.purple,
                                  AppColors.containerHigh,
                                ),
                                useMinimumSize: false,
                                child: Text(path[idx]),
                                onPressed: () {},
                              ),
                              separatorBuilder: (_, _) => Padding(
                                padding: const .symmetric(horizontal: 4),
                                child: OsuButton(
                                  borderRadius: .circular(2),
                                  color: AppColors.containerHigh,
                                  useMinimumSize: false,
                                  child: const Text("/"),
                                ),
                              ),
                            ),
                          ),
                        ),

                        Expanded(
                          child: ScrollConfiguration(
                            behavior: defaultScrollBehavior,
                            child: ListView.builder(
                              itemBuilder: (_, idx) => InkWell(
                                onTap: () {},
                                borderRadius: .circular(2),
                                child: Padding(
                                  padding: const .symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  child: Row(
                                    spacing: 4,
                                    children: [
                                      const Icon(Icons.image, size: 8),
                                      Text(
                                        "Content $idx",
                                        style: const TextStyle(fontSize: 8),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          ActionsBar(
            onBack: () => context.go("/songs"),
            trailing: SkewedBox(
              width: 112,
              decoration: BoxDecoration(
                borderRadius: .circular(4),
                color: AppColors.purple,
              ),
              useGradientBorder: true,
              margin: const .only(right: 18, bottom: 12),
              padding: const .symmetric(vertical: 9, horizontal: 33),
              onTap: () {
                ref.read(beatmapProvider.notifier).pickReplay();
                if (mounted) context.go("/songs");
              },
              child: const Row(
                spacing: 4,
                children: [
                  Icon(Icons.file_open_rounded, size: 8),
                  Text("Pick file", style: TextStyle(fontSize: 8)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
