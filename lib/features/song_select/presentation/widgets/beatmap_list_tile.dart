import 'package:flosu/shared/domain/beatmap/beatmap_selector.dart';
import 'package:flosu/shared/domain/beatmap/beatmap.dart';
import 'package:flosu/shared/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  void initState() {
    super.initState();
    _setupTrack();
  }

  Future<void> _setupTrack() async {
    ref.read(beatmapSelector.notifier).loadTrack(widget.beatmap);
  }

  void _playTrack() async {
    final current = globalRef.read(beatmapSelector)?.audioPath;

    ref
        .read(beatmapSelector.notifier)
        .selectBeatmap(
          widget.beatmap,
          usePreview: true,
          onlySet: current == widget.beatmap.audioPath,
        );
  }

  double get _opacity {
    if (widget.setSelected) return 1;
    if (widget.selected) return 1;
    if (_hover) return 0.75;
    return 0;
  }

  Offset get _slide {
    if (widget.selected) return Offset.zero;
    if (_hover) return const Offset(1 / 32, 0);
    return const Offset(1 / 16, 0);
  }

  double get _height => widget.setSelected ? 1 : 0;

  BorderRadius get _borderRadius => const BorderRadius.only(
    topLeft: Radius.circular(4),
    bottomLeft: Radius.circular(4),
  );

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
          alignment: Alignment.topCenter,
          heightFactor: _height,
          child: ClipRect(
            child: Container(
              margin: const EdgeInsets.only(left: 16, bottom: 2),
              decoration: BoxDecoration(
                borderRadius: _borderRadius,
                color: Color.lerp(Colors.grey, Colors.black, 0.5),
              ),
              child: InkWell(
                borderRadius: _borderRadius,
                onHover: (hover) {
                  if (mounted) setState(() => _hover = hover);
                },
                onTap: _playTrack,
                mouseCursor: SystemMouseCursors.none,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    spacing: 2,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: widget.beatmap.version,
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            ),
                            const TextSpan(
                              text: " mapped by ",
                              style: TextStyle(fontSize: 8, height: 1),
                            ),
                            TextSpan(
                              text: widget.beatmap.creator,
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
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
        ),
      ),
    );
  }
}
