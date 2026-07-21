import 'package:flosu/core/constants.dart';
import 'package:flosu/core/mixins.dart';
import 'package:flosu/features/gameplay/domain/gameplay_data.dart';
import 'package:flosu/models/inputs/inputs.dart';
import 'package:flosu/shared/widgets/actions_bar.dart';
import 'package:flosu/shared/widgets/top_banner.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/models/mods/base.dart';
import 'package:flosu/core/extensions/ui.dart';
import 'package:flosu/ui/shared/animatable_page.dart';
import 'package:flosu/shared/widgets/skewed_box.dart';
import 'package:flosu/features/song_select/presentation/widgets/mod_icon.dart';
import 'package:flosu/features/song_select/presentation/widgets/mod_item.dart';

class ModsPage extends AnimatablePage {
  const ModsPage({super.key, required super.uri});

  @override
  AnimatablePageState<ModsPage> createState() => _ModsPageState();
}

class _ModsPageState extends AnimatablePageState<ModsPage>
    with KeyboardEventHandler {
  @override
  Map<KeysState, VoidCallback> get keyHandlers => {
    // If escape key is pressed, go back
    KeysState({.escape}): _goBack,
  };

  void _goBack() {
    if (mounted) context.go("/songs");
  }

  @override
  Widget buildPage(BuildContext context, double animProgress) {
    final details = ref.watch(gameplayDataProvider);
    final detailsManager = ref.read(gameplayDataProvider.notifier);

    return ColoredBox(
      color: Colors.black38,
      child: Stack(
        alignment: .bottomCenter,
        children: [
          //Mods container
          Column(
            children: [
              const TopBanner(
                title: "Mod selection",
                description:
                    "Mods offer different ways to enjoy the game. Some affect the score "
                    "you can achieve during a ranked match. Others are just for fun.",
              ),
              Expanded(
                child: Align(
                  alignment: .bottomCenter,
                  child: Container(
                    margin: const .only(bottom: 48),
                    constraints: const BoxConstraints(maxHeight: 256),
                    child: SkewedBox.container(
                      child: ScrollConfiguration(
                        behavior: defaultScrollBehavior,
                        child: ListView.separated(
                          shrinkWrap: true,
                          clipBehavior: .none,
                          padding: const .symmetric(horizontal: 96),
                          scrollDirection: .horizontal,
                          itemCount: ConfigurableMod.diffSections.length,
                          //Mods section container
                          itemBuilder: (_, i) {
                            final direction = i.isEven ? 1 : -1;

                            final sectionName = ConfigurableMod
                                .diffSections
                                .keys
                                .elementAt(i);
                            final mods = ConfigurableMod.diffSections.values
                                .elementAt(i);

                            return Transform.translate(
                              offset: Offset(
                                0,
                                (context.screenScaled.height - 192) *
                                    (1 - animProgress) *
                                    direction,
                              ),
                              child: Container(
                                width: 192,
                                isAntiAlias: true,
                                decoration: BoxDecoration(
                                  borderRadius: .circular(6),
                                  color: mods.first.color,
                                ),
                                child: Column(
                                  crossAxisAlignment: .stretch,
                                  children: [
                                    SkewedBox.ignoreParentSkew(
                                      padding: const .symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        sectionName,
                                        style: const TextStyle(
                                          fontSize: 8,
                                          fontWeight: .bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: CustomPaint(
                                        foregroundPainter:
                                            SkewedBoxGradientBorderPainter(
                                              decoration: BoxDecoration(
                                                borderRadius: .circular(6),
                                                color: const Color(0xff2e382f),
                                              ),
                                              width: 1.5,
                                            ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: .circular(6),
                                            color: const Color(0xff2e382f),
                                          ),
                                          child: Align(
                                            alignment: .topCenter,
                                            child: ListView.separated(
                                              physics:
                                                  const RangeMaintainingScrollPhysics(
                                                    parent:
                                                        BouncingScrollPhysics(),
                                                  ),
                                              itemCount: mods.length,
                                              shrinkWrap: true,
                                              padding: const .all(4),
                                              itemBuilder: (_, j) {
                                                final mod = mods.elementAt(j);

                                                return ModItem(
                                                  mod: mod,
                                                  selected: details.mods.any(
                                                    ((m) => m.mod == mod.mod),
                                                  ),
                                                  onTap: () => detailsManager
                                                      .toggleMod(mod),
                                                );
                                              },
                                              separatorBuilder: (_, _) =>
                                                  const SizedBox(height: 4),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          ActionsBar(
            onBack: () => context.go("/songs"),
            actionsPadding: const .only(bottom: 12, left: 18, right: 12),
            actions: [
              SkewedBox(
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: .circular(4),
                  color: AppColors.background,
                ),
                useGradientBorder: true,
                padding: const .only(left: 12),
                child: Row(
                  mainAxisAlignment: .center,
                  children: [
                    if (details.mods.isNotEmpty) ...[
                      for (final mod in details.mods) ModIcon.display(mod: mod),
                      const SizedBox(width: 8),
                    ],

                    Text(
                      details.mods.isEmpty ? "No mods" : details.modsName,
                      style: const TextStyle(fontSize: 8, height: 1),
                    ),
                    const SizedBox(width: 9),
                    //Deselect mods
                    SkewedBox(
                      opacity: details.mods.isNotEmpty ? 1 : 0,
                      decoration: BoxDecoration(
                        borderRadius: .circular(4),
                        color: AppColors.container,
                      ),
                      useGradientBorder: true,
                      padding: const .all(9),
                      onTap: detailsManager.clearMods,
                      child: const Text(
                        "Deselect all",
                        style: TextStyle(fontSize: 8),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),
              //SR and difficulty applied
              SkewedBox(
                decoration: BoxDecoration(
                  borderRadius: .circular(4),
                  color: AppColors.background,
                ),
                useGradientBorder: true,
                padding: const .only(right: 12),
                child: Row(
                  spacing: 12,
                  children: [
                    SkewedBox(
                      decoration: BoxDecoration(
                        borderRadius: .circular(4),
                        color: AppColors.container,
                      ),
                      useGradientBorder: true,
                      padding: const .all(9),
                      child: const Text("0.00*", style: TextStyle(fontSize: 8)),
                    ),
                    const Text(
                      "Difficulty applied",
                      style: TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),

              //Ranked state and multiplier
              SkewedBox(
                decoration: BoxDecoration(
                  borderRadius: .circular(4),
                  color: AppColors.background,
                ),
                useGradientBorder: true,
                padding: const .only(right: 12),
                margin: const .only(left: 6),
                child: Row(
                  spacing: 12,
                  children: [
                    SkewedBox(
                      decoration: BoxDecoration(
                        borderRadius: .circular(4),
                        color: details.isRanked
                            ? AppColors.container
                            : AppColors.yellow,
                      ),
                      useGradientBorder: details.isRanked,
                      padding: const .all(9),
                      child: Text(
                        details.isRanked ? "Ranked" : "Unranked",
                        style: TextStyle(
                          fontSize: 8,
                          color: details.isRanked
                              ? Colors.white
                              : AppColors.background,
                          fontWeight: details.isRanked ? .normal : .bold,
                        ),
                      ),
                    ),

                    TweenAnimationBuilder(
                      tween: Tween(end: details.modMultiplier),
                      duration: Durations.short4,
                      curve: Curves.easeOut,
                      builder: (_, t, _) => Text(
                        "${t.toStringAsFixed(2)}x",
                        style: TextStyle(
                          fontSize: 8,
                          color: t != 1
                              ? t > 1
                                    ? AppColors.red
                                    : AppColors.green
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
