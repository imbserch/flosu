import 'package:flosu/core/extensions/ui.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/features/song_select/presentation/widgets/beatmap_difficulty_item.dart';
import 'package:flosu/shared/domain/beatmap/beatmap.dart';
import 'package:flosu/shared/widgets/skewed_box.dart';
import 'package:flutter/material.dart' hide Slider;

/// A widget that displays the metadata and difficulty of a beatmap like
/// title, artist, difficulty, etc.
class BeatmapInfo extends StatelessWidget {
  const BeatmapInfo({
    super.key,
    required this.beatmap,
    required this.difficulty,
    this.compactView = false,
  });

  final Beatmap beatmap;
  final Difficulty difficulty;
  final bool compactView;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      child: Transform.translate(
        offset: const Offset(-32, 0),
        child: SkewedBox(
          constraints: BoxConstraints(maxWidth: context.screenScaled.width / 2),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 2 / 3),
          ),
          clipBehavior: .antiAlias,
          child: Column(
            crossAxisAlignment: .stretch,
            children: [
              Padding(
                padding: .only(top: 20, left: compactView ? 48 : 40),
                child: Column(
                  crossAxisAlignment: .stretch,
                  children: [
                    Text(
                      beatmap.title,
                      maxLines: compactView ? 2 : 1,
                      overflow: .ellipsis,
                      style: const TextStyle(
                        fontWeight: .w600,
                        fontSize: 16,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      beatmap.artist,
                      style: const TextStyle(fontSize: 8, height: 1),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      spacing: 4,
                      children: [
                        SkewedBox(
                          decoration: BoxDecoration(
                            borderRadius: .circular(2),
                            color: AppColors.containerLow.withValues(
                              alpha: 2 / 3,
                            ),
                          ),
                          padding: const .symmetric(horizontal: 4),
                          child: const Row(
                            spacing: 2,
                            crossAxisAlignment: .center,
                            children: [
                              Icon(Icons.play_arrow_outlined, size: 10),
                              Text("0", style: TextStyle(fontSize: 9)),
                            ],
                          ),
                        ),
                        SkewedBox(
                          decoration: BoxDecoration(
                            borderRadius: .circular(2),
                            color: AppColors.containerLow.withValues(
                              alpha: 2 / 3,
                            ),
                          ),
                          padding: const .symmetric(horizontal: 4),
                          child: const Row(
                            spacing: 2,
                            crossAxisAlignment: .center,
                            children: [
                              Icon(Icons.favorite_border, size: 10),
                              Text("0", style: TextStyle(fontSize: 9)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: .circular(2),
                  color: AppColors.background.withValues(alpha: 2 / 3),
                ),
                child: Column(
                  crossAxisAlignment: .stretch,
                  children: [
                    Padding(
                      padding: .fromLTRB(compactView ? 48 : 40, 4, 4, 4),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: beatmap.version,
                              style: const TextStyle(fontWeight: .bold),
                            ),
                            const TextSpan(text: " mapped by "),
                            TextSpan(
                              text: beatmap.creator,
                              style: const TextStyle(
                                fontWeight: .bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        style: const TextStyle(
                          fontSize: 8,
                          height: 1,
                          color: AppColors.yellow,
                        ),
                      ),
                    ),
                    if (!compactView)
                      Container(
                        padding: const .symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: .circular(2),
                          color: AppColors.background,
                        ),
                        child: Padding(
                          padding: const .only(left: 40, right: 16),
                          child: Row(
                            spacing: 4,
                            children: [
                              BeatmapDifficultyItem(
                                width: 30,
                                label: "Circles",
                                max: beatmap.hitObjectsCount,
                                value: beatmap.hitCircles,
                                color: beatmap.colors[0],
                              ),
                              BeatmapDifficultyItem(
                                width: 30,
                                label: "Sliders",
                                max: beatmap.hitObjectsCount,
                                value: beatmap.sliders,
                                color: beatmap.colors[0],
                              ),
                              BeatmapDifficultyItem(
                                width: 30,
                                label: "Spinners",
                                max: beatmap.hitObjectsCount,
                                value: beatmap.spinners,
                                color: beatmap.colors[0],
                              ),
                              const Spacer(),
                              BeatmapDifficultyItem(
                                label: "Circle Size",
                                max: 10,
                                value: difficulty.circleSize,
                                color: beatmap.colors[0],
                              ),
                              BeatmapDifficultyItem(
                                label: "Accuracy",
                                max: 10,
                                value: difficulty.overallDifficulty,
                                color: beatmap.colors[0],
                              ),
                              BeatmapDifficultyItem(
                                label: "HP Drain",
                                max: 10,
                                value: difficulty.hpDrain,
                                color: beatmap.colors[0],
                              ),
                              BeatmapDifficultyItem(
                                label: "Approach Rate",
                                max: 10,
                                value: difficulty.approachRate,
                                color: beatmap.colors[0],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
