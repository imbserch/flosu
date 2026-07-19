import 'package:flosu/logic/providers/gameplay_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/core/extensions/ui.dart';
import 'package:flosu/shared/widgets/skewed_box.dart';

class CurrentBeatmapInfo extends ConsumerWidget {
  const CurrentBeatmapInfo({super.key, required this.animProgress});
  final double animProgress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(gameplayDataProvider);

    if (details.metadata == null) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: -context.screenScaled.width / 8 * (1 - animProgress),
      width: context.screenScaled.width / 2,
      height: context.screenScaled.height - 32,
      child: Opacity(
        opacity: animProgress,
        child: Column(
          spacing: 2,
          crossAxisAlignment: .stretch,
          children: [
            //Beatmap info
            SkewedBox(
              offset: const Offset(-24, 0),
              useGradientBorder: true,
              decoration: const BoxDecoration(color: AppColors.background),
              child: Column(
                crossAxisAlignment: .stretch,
                mainAxisSize: .min,
                children: [
                  SkewedBox(
                    offset: const Offset(2, 0),
                    decoration: const BoxDecoration(color: AppColors.container),
                    child: Padding(
                      padding: const .fromLTRB(104, 8, 8, 8),
                      child: Column(
                        crossAxisAlignment: .stretch,
                        mainAxisSize: .min,
                        children: [
                          Text(
                            details.metadata!.info.title,
                            maxLines: 2,
                            overflow: .ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: .w700,
                              height: 1,
                            ),
                          ),
                          Text(
                            details.metadata!.info.artist,
                            maxLines: 1,
                            overflow: .ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: .bold,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const .fromLTRB(104, 8, 8, 8),
                    child: Text(
                      "${details.metadata!.info.version} mapped by ${details.metadata!.info.creator}",
                      maxLines: 1,
                      overflow: .ellipsis,
                      style: const TextStyle(fontSize: 8, height: 1),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            //Beatmap details separator
            const SkewedBox(
              decoration: BoxDecoration(color: AppColors.background),
              offset: Offset(-40, 0),
              padding: .fromLTRB(108, 8, 8, 8),
              child: Text("Details", style: TextStyle(fontSize: 8, height: 1)),
            ),

            //Beatmap real details
            SkewedBox(
              useGradientBorder: true,
              decoration: const BoxDecoration(color: AppColors.background),
              offset: const Offset(-50, 0),
              padding: const .fromLTRB(108, 8, 16, 8),
              child: Column(
                spacing: 8,
                children: [
                  //Source and creator
                  Row(
                    crossAxisAlignment: .start,
                    children: [
                      Expanded(
                        child: Column(
                          spacing: 2,
                          crossAxisAlignment: .stretch,
                          children: [
                            const Text(
                              "Source",
                              style: TextStyle(fontSize: 5.5, height: 1),
                            ),
                            Text(
                              details.metadata!.info.source,
                              maxLines: 1,
                              overflow: .ellipsis,
                              style: const TextStyle(
                                fontSize: 6,
                                height: 1,
                                color: Color(0xff8dada3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          spacing: 2,
                          crossAxisAlignment: .stretch,
                          children: [
                            const Text(
                              "Creator",
                              style: TextStyle(fontSize: 5.5, height: 1),
                            ),
                            Text(
                              details.metadata!.info.creator,
                              maxLines: 1,
                              overflow: .ellipsis,
                              style: const TextStyle(
                                fontSize: 6,
                                height: 1,
                                color: Color(0xff8dada3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  //Beatmap id
                  Column(
                    spacing: 2,
                    crossAxisAlignment: .stretch,
                    children: [
                      const Text(
                        "Beatmap id",
                        style: TextStyle(fontSize: 5.5, height: 1),
                      ),
                      Text(
                        "${details.metadata!.general.beatmapSetId ?? -1}",
                        style: const TextStyle(
                          fontSize: 6,
                          height: 1,
                          color: Color(0xff8dada3),
                        ),
                      ),
                    ],
                  ),

                  //Tags
                  Column(
                    spacing: 2,
                    crossAxisAlignment: .stretch,
                    children: [
                      const Text(
                        "Tags",
                        style: TextStyle(fontSize: 5.5, height: 1),
                      ),
                      Text(
                        details.metadata!.info.tags,
                        maxLines: 1,
                        overflow: .ellipsis,
                        style: const TextStyle(
                          fontSize: 6,
                          height: 1,
                          color: Color(0xff8dada3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
