import 'dart:ui';

import 'package:flosu/logic/providers/gameplay_data.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/models/mods/base.dart';
import 'package:flosu/core/extensions/ui.dart';
import 'package:flosu/ui/shared/animatable_page.dart';
import 'package:flosu/ui/widgets/common/skewed_box.dart';
import 'package:flosu/ui/widgets/song_select/mod_icon.dart';
import 'package:flosu/ui/widgets/song_select/mod_item.dart';

class ModsPage extends AnimatablePage {
  const ModsPage({super.key, required super.uri});

  @override
  AnimatablePageState<ModsPage> createState() => _ModsPageState();
}

class _ModsPageState extends AnimatablePageState<ModsPage> {
  @override
  Widget buildPage(BuildContext context, double animProgress) {
    final details = ref.watch(gameplayDataProvider);
    final detailsManager = ref.read(gameplayDataProvider.notifier);

    return ColoredBox(
      color: Colors.black38,
      child: Stack(
        alignment: .bottomCenter,
        children: [
          //Mod selection description
          Align(
            alignment: .topCenter,
            child: Container(
              margin: const .symmetric(horizontal: 24),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: .circular(8),
                  bottomRight: .circular(8),
                ),
                color: Color(0xff293d2a),
              ),
              child: Container(
                margin: const .only(bottom: 8),
                padding: const .symmetric(horizontal: 64, vertical: 10),
                decoration: BoxDecoration(
                  border: BoxBorder.fromLTRB(
                    bottom: const BorderSide(color: Color(0xff38543a)),
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: .circular(8),
                    bottomRight: .circular(8),
                  ),
                  color: const Color(0xff334c35),
                ),
                child: const Column(
                  spacing: 2,
                  mainAxisSize: .min,
                  crossAxisAlignment: .stretch,
                  children: [
                    Text(
                      "Mod selection",
                      style: TextStyle(fontSize: 12, height: 1),
                    ),
                    Text(
                      "Mods offer different ways to enjoy the game. Some affect the score "
                      "you can achieve during a ranked match. Others are just for fun.",
                      style: TextStyle(fontSize: 6, height: 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -48,
            right: -48,
            bottom: 36,
            height: 312,
            child: Padding(
              padding: const .only(bottom: 24),

              child: SkewedBox.container(
                child: ScrollConfiguration(
                  behavior: const MaterialScrollBehavior().copyWith(
                    scrollbars: false,
                    overscroll: false,
                    dragDevices: PointerDeviceKind.values.toSet(),
                    physics: const BouncingScrollPhysics(),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    clipBehavior: .none,
                    padding: const .symmetric(horizontal: 96),
                    scrollDirection: .horizontal,
                    itemCount: ConfigurableMod.diffSections.length,
                    //Mods section container
                    itemBuilder: (_, i) {
                      final direction = i.isEven ? 1 : -1;

                      final sectionName = ConfigurableMod.diffSections.keys
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
                                    child: ScrollConfiguration(
                                      behavior: const MaterialScrollBehavior()
                                          .copyWith(
                                            scrollbars: false,
                                            overscroll: false,
                                            dragDevices: PointerDeviceKind
                                                .values
                                                .toSet(),
                                          ),
                                      child: Align(
                                        alignment: .topCenter,
                                        child: ListView.separated(
                                          itemCount: mods.length,
                                          shrinkWrap: true,
                                          padding: const .all(4),
                                          itemBuilder: (_, j) {
                                            final mod = mods.elementAt(j);

                                            return ModItem(
                                              mod: mod,
                                              selected: details.mods.any(
                                                ((m) =>
                                                    m.acronym == mod.acronym),
                                              ),
                                              onTap: () =>
                                                  detailsManager.toggleMod(mod),
                                            );
                                          },
                                          separatorBuilder: (_, _) =>
                                              const SizedBox(height: 4),
                                        ),
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
          Container(color: AppColors.background, height: 32),
          Row(
            crossAxisAlignment: .end,
            children: [
              SkewedBox(
                heroTag: "Back button",
                decoration: BoxDecoration(
                  borderRadius: .circular(4),
                  color: AppColors.fucshia,
                ),
                useGradientBorder: true,
                margin: const .fromLTRB(18, 0, 0, 12),
                padding: const .symmetric(vertical: 9, horizontal: 33),
                onTap: () => context.go("/songs"),
                child: const Text("Back", style: TextStyle(fontSize: 8)),
              ),
              SkewedBox(
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: .circular(4),
                  color: AppColors.background,
                ),
                useGradientBorder: true,
                margin: const .fromLTRB(18, 0, 0, 12),
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
                margin: const .fromLTRB(18, 0, 0, 12),
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
                margin: const .fromLTRB(18, 0, 12, 12),
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
