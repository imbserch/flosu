import 'package:flosu/core/constants.dart';
import 'package:flosu/core/extensions/models.dart';
import 'package:flosu/features/song_select/domain/mod_group.dart';
import 'package:flosu/shared/domain/beatmap/beatmap_selector.dart';
import 'package:flosu/shared/domain/mod/mod_selector.dart';
import 'package:flosu/shared/widgets/actions_bar.dart';
import 'package:flosu/shared/widgets/top_banner.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/core/extensions/ui.dart';
import 'package:flosu/shared/layout/animatable_page.dart';
import 'package:flosu/shared/widgets/skewed_box.dart';
import 'package:flosu/features/song_select/presentation/widgets/mod_icon.dart';
import 'package:flosu/features/song_select/presentation/widgets/mod_item.dart';

import '../../../../shared/input.dart';

class ModsPage extends AnimatablePage {
  const ModsPage({super.key, required super.uri});

  @override
  AnimatablePageState<ModsPage> createState() => _ModsPageState();
}

class _ModsPageState extends AnimatablePageState<ModsPage>
    with KeyboardHandler {
  void _goBack() {
    if (mounted) context.go("/songs");
  }

  @override
  bool input() {
    if (!keyboard.pressed) return false;

    switch (keyboard.key) {
      case .escape:
        _goBack();
        return true;
      default:
        return false;
    }
  }

  @override
  Widget buildPage(BuildContext context) {
    final modsManager = ref.read(modSelector.notifier);

    final mods = ref.watch(modSelector);
    final isRanked = ref.watch(modsRankedProvider);
    final modMultiplier = ref.watch(scoreMultiplierProvider);
    // final difficulty = ref.watch(difficultyProvider);

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
                          itemCount: ModGroups.all.length,
                          //Mods section container
                          itemBuilder: (_, i) {
                            final direction = i.isEven ? 1 : -1;

                            final modGroup = ModGroups.all[i];

                            return Transform.translate(
                              offset: Offset(
                                0,
                                (context.screenScaled.height - 192) *
                                    (1 - t) *
                                    direction,
                              ),
                              child: Container(
                                width: 192,
                                isAntiAlias: true,
                                decoration: BoxDecoration(
                                  borderRadius: .circular(6),
                                  color: modGroup.color,
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
                                        modGroup.type,
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
                                              itemCount: modGroup.mods.length,
                                              shrinkWrap: true,
                                              padding: const .all(4),
                                              itemBuilder: (_, j) {
                                                final mod = modGroup.mods[j];

                                                return ModItem(
                                                  mod: mod,
                                                  selected: mods.containsMod(
                                                    mod.info,
                                                  ),
                                                  onTap: () => modsManager
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
                    if (mods.isNotEmpty) ...[
                      for (final mod in mods) ModIcon.display(mod: mod),
                      const SizedBox(width: 8),
                    ],

                    Text(
                      mods.isEmpty
                          ? "No mods"
                          : mods.map((e) => e.info.acronym).join(),
                      style: const TextStyle(fontSize: 8, height: 1),
                    ),
                    const SizedBox(width: 9),
                    //Deselect mods
                    SkewedBox(
                      opacity: mods.isNotEmpty ? 1 : 0,
                      decoration: BoxDecoration(
                        borderRadius: .circular(4),
                        color: AppColors.container,
                      ),
                      useGradientBorder: true,
                      padding: const .all(9),
                      onTap: modsManager.clearMods,
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
                        color: isRanked
                            ? AppColors.container
                            : AppColors.yellow,
                      ),
                      useGradientBorder: isRanked,
                      padding: const .all(9),
                      child: Text(
                        isRanked ? "Ranked" : "Unranked",
                        style: TextStyle(
                          fontSize: 8,
                          color: isRanked ? Colors.white : AppColors.background,
                          fontWeight: isRanked ? .normal : .bold,
                        ),
                      ),
                    ),

                    TweenAnimationBuilder(
                      tween: Tween(end: modMultiplier),
                      duration: Durations.short4,
                      curve: Curves.fastOutSlowIn,
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
