import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/models/mods/base.dart';
import 'package:flosu/core/extensions/ui.dart';
import 'package:flosu/logic/providers/gameplay_service.dart';
import 'package:flosu/logic/providers/tooltip.dart';
import 'package:flosu/ui/shared/animatable_page.dart';
import 'package:flosu/ui/widgets/common/skewed_box.dart';

class ModsPage extends AnimatablePage {
  const ModsPage({super.key, required super.uri});

  @override
  AnimatablePageState<ModsPage> createState() => _ModsPageState();
}

class _ModsPageState extends AnimatablePageState<ModsPage> {
  @override
  Widget buildPage(BuildContext context, double animProgress) {
    final selectedMods = ref.watch(gameplayService);
    final modsManager = ref.read(gameplayService.notifier);

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
                                              selected: selectedMods.mods.any(
                                                ((m) =>
                                                    m.acronym == mod.acronym),
                                              ),
                                              onTap: () =>
                                                  modsManager.toggleMod(mod),
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
                    if (selectedMods.mods.isNotEmpty) ...[
                      for (final mod in selectedMods.mods)
                        ModIcon.display(mod: mod),
                      const SizedBox(width: 8),
                    ],

                    Text(
                      selectedMods.mods.isEmpty
                          ? "No mods"
                          : selectedMods.modsName,
                      style: const TextStyle(fontSize: 8, height: 1),
                    ),
                    const SizedBox(width: 9),
                    //Deselect mods
                    SkewedBox(
                      opacity: selectedMods.mods.isNotEmpty ? 1 : 0,
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
                        color: selectedMods.isRanked
                            ? AppColors.container
                            : AppColors.yellow,
                      ),
                      useGradientBorder: selectedMods.isRanked,
                      padding: const .all(9),
                      child: Text(
                        selectedMods.isRanked ? "Ranked" : "Unranked",
                        style: TextStyle(
                          fontSize: 8,
                          color: selectedMods.isRanked
                              ? Colors.white
                              : AppColors.background,
                          fontWeight: selectedMods.isRanked ? .normal : .bold,
                        ),
                      ),
                    ),

                    TweenAnimationBuilder(
                      tween: Tween(end: selectedMods.modMultiplier),
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

class ModItem extends ConsumerWidget {
  const ModItem({
    super.key,
    required this.mod,
    required this.selected,
    required this.onTap,
  });

  final ConfigurableMod mod;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tooltipManager = ref.read(tooltipProvider.notifier);

    return TweenAnimationBuilder(
      tween: Tween(end: selected ? 1.0 : 0.0),
      duration: Durations.short1,
      curve: Curves.easeIn,
      builder: (_, t, _) => SkewedBox.ignoreParentSkew(
        onTap: onTap,
        useGradientBorder: true,
        decoration: BoxDecoration(
          borderRadius: .circular(4),
          color: Color.lerp(const Color(0xff39463a), mod.color, t / 3),
        ),
        child: MouseRegion(
          onEnter: (_) => tooltipManager.showTooltip(
            Column(
              crossAxisAlignment: .stretch,
              mainAxisSize: .min,
              children: [
                Text(mod.description),
                if (mod.incompatibleMods.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    "Incompatible with",
                    style: TextStyle(fontSize: 6),
                  ),
                  Row(
                    children: [
                      for (final incompatibleMod in mod.incompatibleMods)
                        ModIcon(mod: incompatibleMod, selected: true, size: 12),
                    ],
                  ),
                ],
              ],
            ),
          ),
          onExit: (_) => tooltipManager.hideTooltip(),
          child: Row(
            children: [
              SkewedBox(
                padding: const .symmetric(vertical: 4, horizontal: 6),
                child: ModIcon(mod: mod, selected: selected),
              ),
              Expanded(
                child: SkewedBox(
                  margin: const .only(right: 4),
                  padding: const .symmetric(vertical: 4, horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: .circular(4),
                    color: Color.lerp(const Color(0xff455446), mod.color, t),
                  ),
                  child: Column(
                    crossAxisAlignment: .stretch,
                    children: [
                      Text(
                        mod.name,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: .w700,
                          color: Color.lerp(Colors.white, Colors.black, t),
                        ),
                      ),
                      Text(
                        mod.description,
                        maxLines: 1,
                        overflow: .ellipsis,
                        style: TextStyle(
                          fontSize: 6,
                          color: Color.lerp(Colors.white, Colors.black, t),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModIcon extends StatelessWidget {
  const ModIcon({
    super.key,
    required this.mod,
    required this.selected,
    this.size = 20,
  }) : isDisplay = false;

  const ModIcon.display({super.key, required this.mod, this.size = 12})
    : selected = true,
      isDisplay = true;

  final ConfigurableMod mod;
  final bool selected;
  final double size;

  final bool isDisplay;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      child: Align(
        widthFactor: isDisplay ? .45 : 1,
        child: Transform.rotate(
          angle: 1 / 2,
          child: TweenAnimationBuilder(
            tween: Tween(end: selected ? 1.0 : 0.0),
            duration: Durations.short1,
            curve: Curves.easeIn,
            builder: (_, t, _) => Container(
              decoration: ShapeDecoration(
                color: Color.lerp(const Color(0xff455446), mod.color, t),
                shape: const StarBorder.polygon(pointRounding: .25, sides: 6),
              ),
              child: Transform.rotate(
                angle: -1 / 2,
                child: SizedBox.square(
                  dimension: size,
                  child: Image.asset(
                    mod.assetPath,
                    width: size,
                    height: size,
                    color: Color.lerp(Colors.white, Colors.black, t),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
