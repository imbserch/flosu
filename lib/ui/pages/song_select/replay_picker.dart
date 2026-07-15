import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/logic/providers/library.dart';
import 'package:flosu/ui/shared/animatable_page.dart';
import 'package:flosu/ui/widgets/common/actions_bar.dart';
import 'package:flosu/ui/widgets/common/skewed_box.dart';
import 'package:flosu/ui/widgets/common/top_banner.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReplayPickerPage extends AnimatablePage {
  const ReplayPickerPage({super.key, required super.uri});

  @override
  AnimatablePageState<ReplayPickerPage> createState() =>
      _ReplayPickerPageState();
}

class _ReplayPickerPageState extends AnimatablePageState<ReplayPickerPage> {
  @override
  Widget buildPage(BuildContext context, double t) {
    return ColoredBox(
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
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: .center,
                    crossAxisAlignment: .center,
                    mainAxisSize: .min,
                    spacing: 12,
                    children: [
                      const Text("Pick your file here"),
                      SkewedBox(
                        width: 112,
                        decoration: BoxDecoration(
                          borderRadius: .circular(4),
                          color: AppColors.purple,
                        ),
                        useGradientBorder: true,
                        padding: const .symmetric(vertical: 9, horizontal: 33),
                        onTap: () {
                          ref.read(libraryProvider.notifier).pickReplay();
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
                    ],
                  ),
                ),
              ),
            ],
          ),
          ActionsBar(
            onBack: () => context.go("/songs"),
            // This button will be enabled when internal picker is implemented
            /* trailing: SkewedBox(
              decoration: BoxDecoration(
                borderRadius: .circular(4),
                color: AppColors.purple,
              ),
              useGradientBorder: true,
              margin: const .fromLTRB(0, 12, 18, 12),
              padding: const .symmetric(vertical: 9, horizontal: 33),
              onTap: () {},
              child: const Row(
                spacing: 4,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 8),
                  Text("Select", style: TextStyle(fontSize: 8)),
                ],
              ),
            ), */
          ),
        ],
      ),
    );
  }
}
