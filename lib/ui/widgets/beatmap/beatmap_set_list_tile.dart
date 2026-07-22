import 'dart:io';

import 'package:flosu/features/audio/data/audio_provider.dart'
    show audioProvider;
import 'package:flosu/models/generated/beatmap_metadata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_fade/image_fade.dart';

class BeatmapSetListTile extends ConsumerStatefulWidget {
  const BeatmapSetListTile({
    super.key,
    required this.beatmap,
    required this.selected,
  });

  final BeatmapMetadata beatmap;
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
    if (widget.selected) return Offset.zero;
    if (_hover) return const Offset(1 / 32, 0);
    return const Offset(1 / 16, 0);
  }

  BorderSide get _borderSide => BorderSide(
    width: 1,
    color: Color.lerp(Colors.grey, Colors.black, 2 / 5)!,
  );

  BorderRadius get _borderRadius => const BorderRadius.only(
    topLeft: Radius.circular(4),
    bottomLeft: Radius.circular(4),
  );

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
            onTap: () async {
              final path = ref.read(audioProvider)?.general.audioPath;
              final audio = ref.read(audioProvider.notifier);
              await audio.load(widget.beatmap);
              audio.preview(
                widget.beatmap,
                path != widget.beatmap.general.audioPath,
              );
            },
            mouseCursor: SystemMouseCursors.none,
            borderRadius: _borderRadius,
            child: Container(
              clipBehavior: Clip.antiAlias,
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
                color: Color.lerp(Colors.grey, Colors.black, 0.5),
              ),
              child: Row(
                spacing: 8,
                children: [
                  SizedBox(
                    width: 200 / 3,
                    height: 50,
                    child: ImageFade(
                      image: widget.beatmap.general.backgroundPath != null
                          ? ResizeImage(
                              FileImage(
                                File(widget.beatmap.general.backgroundPath!),
                              ),
                              width: 160,
                            )
                          : null,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          widget.beatmap.info.title,
                          maxLines: 1,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
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
