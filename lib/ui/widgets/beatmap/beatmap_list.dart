import 'dart:ui';

import 'package:flosu/core/extensions/ui.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/logic/providers/audio.dart';
import 'package:flosu/logic/providers/library.dart';
import 'package:flosu/models/beatmap/beatmap_set.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class BeatmapList extends ConsumerStatefulWidget {
  const BeatmapList({super.key});

  @override
  ConsumerState<BeatmapList> createState() => _BeatmapListState();
}

class _BeatmapListState extends ConsumerState<BeatmapList> {
  final _scrollController = ItemScrollController();
  final _itemListener = ItemPositionsListener.create();

  List<ItemPosition> _itemPositions = [];

  @override
  initState() {
    super.initState();
    _itemListener.itemPositions.addListener(_onItemPositionsChanged);
  }

  @override
  dispose() {
    _itemListener.itemPositions.removeListener(_onItemPositionsChanged);
    super.dispose();
  }

  void _onItemPositionsChanged() {
    _itemPositions = List.of(_itemListener.itemPositions.value);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(libraryProvider);

    return ScrollConfiguration(
      behavior: const MaterialScrollBehavior().copyWith(
        scrollbars: false,
        dragDevices: PointerDeviceKind.values.toSet(),
        physics: const BouncingScrollPhysics(),
      ),
      child: ScrollablePositionedList.separated(
        itemCount: groups.length,
        itemPositionsListener: _itemListener,
        itemScrollController: _scrollController,
        padding: .symmetric(vertical: (context.screenScaled.height - 60) * .45),
        itemBuilder: (_, index) {
          // Find the position of this specific item
          double itemLeadingEdge = 0.0;
          double itemTrailingEdge = 0.0;

          final position = _itemPositions.where((p) => p.index == index);

          if (position.isNotEmpty) {
            itemLeadingEdge = position.first.itemLeadingEdge;
            itemTrailingEdge = position.first.itemTrailingEdge;
          }

          double itemCenter = (itemLeadingEdge + itemTrailingEdge) / 2;

          double distanceToCenter = (0.5 - itemCenter).abs();

          double linearFactor = distanceToCenter.clamp(0.0, 1.0);

          double curvedFactor = Curves.fastOutSlowIn.transform(linearFactor);

          double t = curvedFactor / 8;

          return FractionalTranslation(
            translation: Offset(t + (1 / 80) + 0.05, 0),
            child: BeatmapSetCard(group: groups[index]),
          );
        },
        separatorBuilder: (_, index) => const SizedBox(height: 1),
      ),
    );
  }
}

//TODO: MOVE TO SEPARATE FILE
class BeatmapSetCard extends ConsumerWidget {
  const BeatmapSetCard({super.key, required this.group});

  final BeatmapSet group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final first = group.beatmaps.first;

    return Material(
      color: first.colors.first,
      shape: RoundedRectangleBorder(borderRadius: .circular(4)),
      clipBehavior: .antiAlias,
      /* decoration: BoxDecoration(
        borderRadius: .circular(4),
        boxShadow: [
          BoxShadow(
            color: AppColors.container.withAlpha(128),
            blurRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ), */
      child: InkWell(
        mouseCursor: SystemMouseCursors.none,
        onTap: () => ref.read(audioProvider.notifier).preview(first),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: .circular(4),
            color: AppColors.middle(AppColors.background, first.colors.first),
          ),
          margin: const .only(left: 4),
          padding: const .all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                group.title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: .bold,
                  height: 1,
                ),
              ),
              Text(
                group.artist,
                style: const TextStyle(fontSize: 6, height: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
