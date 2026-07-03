import 'dart:ui';

import 'package:flosu/core/extensions/format.dart';
import 'package:flosu/core/extensions/ui.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/logic/providers/audio.dart';
import 'package:flosu/logic/providers/gameplay_service.dart';
import 'package:flosu/logic/providers/library.dart';
import 'package:flosu/models/beatmap/beatmap.dart';
import 'package:flosu/models/beatmap/beatmap_set.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_fade/image_fade.dart';
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
    final beatmaps = ref.watch(
      libraryProvider.select(
        (it) => it.fold<List<Beatmap>>([], (a, b) => [...a, ...b.beatmaps]),
      ),
    );

    final currentBeatmap = ref.watch(
      gameplayService.select((it) => it.beatmap),
    );

    List<Widget> buildChildren() {
      final widgets = <Widget>[];

      int currentSetCount = 0;
      int currentSet = 0;

      for (int index = 0; index < beatmaps.length; index++) {
        final beatmap = beatmaps[index];
        final nextBeatmap = beatmaps.elementAtOrNull(index + 1);

        if (currentSet != beatmap.groupId) {
          currentSet = beatmap.groupId;
          currentSetCount = -1;
        }

        currentSetCount++;

        final isSetSelected = currentBeatmap?.groupId == beatmap.groupId;
        final isBeatmapSelected = currentBeatmap == beatmap;

        final isFirstOfSet = currentSetCount == 0;

        final isLastOfSet = nextBeatmap != null
            ? nextBeatmap.groupId != beatmap.groupId
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
      behavior: const MaterialScrollBehavior().copyWith(
        scrollbars: false,
        dragDevices: PointerDeviceKind.values.toSet(),
        physics: const BouncingScrollPhysics(),
      ),
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

class BeatmapSetListTile extends ConsumerStatefulWidget {
  const BeatmapSetListTile({
    super.key,
    required this.beatmap,
    required this.selected,
  });

  final Beatmap beatmap;
  final bool selected;

  @override
  ConsumerState<BeatmapSetListTile> createState() => _BeatmapSetListTileState();
}

class _BeatmapSetListTileState extends ConsumerState<BeatmapSetListTile> {
  bool _hover = false;

  double get _opacity {
    if (widget.selected) return 1;
    if (_hover) return 0.75;
    return 0.5;
  }

  Offset get _slide {
    if (widget.selected) return .zero;
    if (_hover) return const Offset(1 / 32, 0);
    return const Offset(1 / 16, 0);
  }

  BorderSide get _borderSide => BorderSide(
    width: 1,
    color: Color.lerp(widget.beatmap.colors.first, Colors.black, 2 / 5)!,
  );

  BorderRadius get _borderRadius =>
      const .only(topLeft: .circular(4), bottomLeft: .circular(4));

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedSlide(
        duration: Durations.medium1,
        curve: Curves.easeOut,
        offset: _slide,
        child: AnimatedOpacity(
          duration: Durations.medium1,
          curve: Curves.easeOut,
          opacity: _opacity,
          child: InkWell(
            onHover: (hover) {
              if (mounted) setState(() => _hover = hover);
            },
            onTap: () =>
                ref.read(audioProvider.notifier).preview(widget.beatmap),
            mouseCursor: SystemMouseCursors.none,
            borderRadius: _borderRadius,
            child: Container(
              clipBehavior: .antiAlias,
              foregroundDecoration: BoxDecoration(
                borderRadius: _borderRadius,
                border: Border(
                  top: _borderSide,
                  left: _borderSide,
                  bottom: _borderSide,
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: _borderRadius,
                color: Color.lerp(
                  widget.beatmap.colors.first,
                  Colors.black,
                  0.5,
                ),
              ),
              child: Row(
                spacing: 8,
                children: [
                  SizedBox(
                    width: 200 / 3,
                    height: 50,
                    child: ImageFade(
                      image: widget.beatmap.background != null
                          ? ResizeImage(
                              FileImage(widget.beatmap.background!.file),
                              width: 160,
                            )
                          : null,
                      fit: .cover,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        Text(
                          widget.beatmap.info.title,
                          maxLines: 1,
                          style: const TextStyle(
                            fontWeight: .bold,
                            fontSize: 12,
                            height: 1,
                          ),
                        ),
                        Text(
                          widget.beatmap.info.artist,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 8, height: 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BeatmapListTile extends ConsumerStatefulWidget {
  const BeatmapListTile({
    super.key,
    required this.beatmap,
    required this.setSelected,
    required this.selected,
  });

  final Beatmap beatmap;
  final bool setSelected;
  final bool selected;

  @override
  ConsumerState<BeatmapListTile> createState() => _BeatmapListTileState();
}

class _BeatmapListTileState extends ConsumerState<BeatmapListTile> {
  bool _hover = false;

  double get _opacity {
    if (widget.setSelected) return 1;
    if (widget.selected) return 1;
    if (_hover) return 0.75;
    return 0;
  }

  Offset get _slide {
    if (widget.selected) return .zero;
    if (_hover) return const Offset(1 / 32, 0);
    return const Offset(1 / 16, 0);
  }

  double get _height => widget.setSelected ? 1 : 0;

  BorderRadius get _borderRadius =>
      const .only(topLeft: .circular(4), bottomLeft: .circular(4));

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: Durations.medium1,
      curve: Curves.easeOut,
      offset: _slide,
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: Durations.medium1,
        curve: Curves.easeOut,
        child: AnimatedAlign(
          duration: Durations.medium1,
          curve: Curves.easeOut,
          alignment: .topCenter,
          heightFactor: _height,
          child: ClipRect(
            child: Container(
              margin: const .only(left: 16, bottom: 2),
              decoration: BoxDecoration(
                borderRadius: _borderRadius,
                color: Color.lerp(
                  widget.beatmap.colors.first,
                  Colors.black,
                  0.5,
                ),
              ),
              child: InkWell(
                borderRadius: _borderRadius,
                onHover: (hover) {
                  if (mounted) setState(() => _hover = hover);
                },
                onTap: () =>
                    ref.read(audioProvider.notifier).preview(widget.beatmap),
                mouseCursor: SystemMouseCursors.none,
                child: Padding(
                  padding: const .all(8),
                  child: Column(
                    spacing: 2,
                    crossAxisAlignment: .stretch,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: widget.beatmap.info.version,
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: .bold,
                                height: 1,
                              ),
                            ),
                            const TextSpan(
                              text: " mapped by ",
                              style: TextStyle(fontSize: 8, height: 1),
                            ),
                            TextSpan(
                              text: widget.beatmap.info.creator,
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: .bold,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        widget.beatmap.drainTime.formatted,
                        style: const TextStyle(fontSize: 6, height: 1),
                      ),
                    ],
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
