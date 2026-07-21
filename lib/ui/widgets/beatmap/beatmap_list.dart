import 'package:flosu/core/constants.dart';
import 'package:flosu/core/extensions/ui.dart';
import 'package:flosu/features/audio/data/audio_provider.dart';
import 'package:flosu/logic/providers/beatmap.dart';
import 'package:flosu/ui/widgets/beatmap/beatmap_list_tile.dart';
import 'package:flosu/ui/widgets/beatmap/beatmap_set_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BeatmapList extends ConsumerStatefulWidget {
  const BeatmapList({super.key});

  @override
  ConsumerState<BeatmapList> createState() => _BeatmapListState();
}

class _BeatmapListState extends ConsumerState<BeatmapList> {
  @override
  Widget build(BuildContext context) {
    final beatmaps = ref.watch(beatmapProvider);

    final currentBeatmap = ref.watch(audioProvider);
    final currentSetId = currentBeatmap?.general.beatmapSetId;

    List<Widget> buildChildren() {
      final widgets = <Widget>[];

      int currentSetCount = 0;
      int currentSet = 0;

      for (int index = 0; index < beatmaps.length; index++) {
        final beatmap = beatmaps[index];
        final nextBeatmap = beatmaps.elementAtOrNull(index + 1);
        final beatmapSetId = beatmap.general.beatmapSetId ?? -1;
        final nextBeatmapSetId = nextBeatmap?.general.beatmapSetId;

        if (currentSet != beatmap.general.beatmapSetId) {
          currentSet = beatmapSetId;
          currentSetCount = -1;
        }

        currentSetCount++;

        final isSetSelected = currentSetId == beatmapSetId;
        final isBeatmapSelected = currentBeatmap == beatmap;

        final isFirstOfSet = currentSetCount == 0;

        final isLastOfSet = nextBeatmap != null
            ? nextBeatmapSetId != beatmapSetId
            : true;

        final child = Padding(
          padding: .only(bottom: isLastOfSet ? 2 : 0),
          child: BeatmapListTile(
            beatmap: beatmap,
            setSelected: isSetSelected,
            selected: isBeatmapSelected,
          ),
        );

        if (isFirstOfSet) {
          widgets.add(
            Column(
              spacing: 2,
              crossAxisAlignment: .stretch,
              children: [
                BeatmapSetListTile(beatmap: beatmap, selected: isSetSelected),
                child,
              ],
            ),
          );
          continue;
        }

        widgets.add(child);
      }
      return widgets;
    }

    return ScrollConfiguration(
      behavior: defaultScrollBehavior,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: .symmetric(vertical: context.screenScaled.height * 0.45),
            sliver: SliverList.list(children: buildChildren()),
          ),
        ],
      ),
    );
  }
}
