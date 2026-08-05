import 'package:flosu/core/constants.dart';
import 'package:flosu/core/extensions/ui.dart';
import 'package:flosu/features/song_select/domain/beatmap_library.dart';
import 'package:flosu/shared/domain/beatmap/beatmap_selector.dart';
import 'package:flosu/features/song_select/presentation/widgets/beatmap_list_tile.dart';
import 'package:flosu/features/song_select/presentation/widgets/beatmap_set_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BeatmapList extends ConsumerStatefulWidget {
  const BeatmapList({super.key});

  @override
  ConsumerState<BeatmapList> createState() => _BeatmapListState();
}

class _BeatmapListState extends ConsumerState<BeatmapList> {
  @override
  Widget build(BuildContext context) {
    final beatmaps = ref.watch(beatmapLibrary);

    final currentBeatmap = ref.watch(beatmapSelector);
    final currentSetId = currentBeatmap?.setId;

    List<Widget> buildChildren() {
      final widgets = <Widget>[];

      int currentSetCount = 0;
      int currentSet = 0;

      for (int index = 0; index < beatmaps.length; index++) {
        final beatmap = beatmaps[index];
        final nextBeatmap = beatmaps.elementAtOrNull(index + 1);
        final beatmapSetId = beatmap.setId;
        final nextBeatmapSetId = nextBeatmap?.setId;

        if (currentSet != beatmap.setId) {
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
        scrollCacheExtent: const ScrollCacheExtent.viewport(3),
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
