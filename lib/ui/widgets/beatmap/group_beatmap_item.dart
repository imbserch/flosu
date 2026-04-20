import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_fade/image_fade.dart';
import 'package:flosu/logic/providers/audio.dart';
import 'package:flosu/models/beatmap/beatmap.dart';
import 'package:flosu/ui/widgets/common/skewed_box.dart';

class GroupBeatmapItem extends ConsumerWidget {
  @Deprecated("Replace")
  const GroupBeatmapItem({
    super.key,
    required this.group,
    required this.onTap,
    required this.onGameplayRequest,
  });

  final VoidCallback onTap, onGameplayRequest;
  final List<Beatmap> group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.read(audioProvider.notifier);

    final current = ref.watch(audioProvider);

    final selected = current != null ? group.contains(current) : false;

    final data = group[0];

    return TweenAnimationBuilder(
      tween: Tween(end: selected ? 1.0 : 0.0),
      curve: Curves.easeOut,
      duration: Durations.medium1,
      builder: (_, t, child) => child!,
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          AnimatedContainer(
            curve: Curves.easeOut,
            duration: Durations.medium1,
            margin: selected
                ? const .fromLTRB(4, 8, 0, 2)
                : const .fromLTRB(4, 2, 0, 2),
            decoration: BoxDecoration(
              color: selected ? Colors.white : const Color(0xff232a28),
              borderRadius: .circular(4),
              boxShadow: [
                if (selected)
                  const BoxShadow(color: Colors.blue, blurRadius: 4),
              ],
            ),
            child: InkWell(
              onTap: () async {
                if (selected) return;

                await audio.preview(data);

                onTap();
              },
              mouseCursor: SystemMouseCursors.none,
              child: Row(
                children: [
                  if (selected)
                    const Padding(
                      padding: .all(4),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 6,
                        color: Colors.black,
                      ),
                    )
                  else
                    const SizedBox(width: 4),
                  Expanded(
                    child: AnimatedContainer(
                      curve: Curves.easeOut,
                      duration: Durations.medium1,
                      margin: selected ? const .fromLTRB(0, 1, 0, 1) : .zero,
                      clipBehavior: .antiAliasWithSaveLayer,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: .circular(4),
                      ),
                      child: Stack(
                        fit: .passthrough,
                        children: [
                          if (data.background?.file != null)
                            ImageFade(
                              image: FileImage(data.background!.file),
                              height: 40,
                              width: double.maxFinite,
                              fit: .cover,
                            ),
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xff2e3834), Colors.transparent],
                                stops: [.125, 1],
                              ),
                            ),
                            padding: const .fromLTRB(8, 6, 0, 8),
                            child: Column(
                              crossAxisAlignment: .stretch,
                              children: [
                                Text(
                                  data.info.title,
                                  maxLines: 1,
                                  overflow: .ellipsis,
                                  style: const TextStyle(
                                    fontSize: 8,
                                    height: 1,
                                  ),
                                ),
                                Text(
                                  data.info.artist,
                                  maxLines: 1,
                                  overflow: .ellipsis,
                                  style: const TextStyle(
                                    fontSize: 6,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xffa3ff54),
                                        borderRadius: .circular(4),
                                      ),
                                      padding: const .fromLTRB(4, 1, 4, 1),
                                      child: Text(
                                        "COMPATIBLE",
                                        style: TextStyle(
                                          height: 1,
                                          fontSize: 6,
                                          fontWeight: .bold,
                                          color: SkewedBox.contrastColor(
                                            const Color(0xffa3ff54),
                                          ),
                                        ),
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
                  ),
                ],
              ),
            ),
          ),
          if (selected)
            Padding(
              padding: const .fromLTRB(36, 2, 0, 8),
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: group.length,
                shrinkWrap: true,
                separatorBuilder: (_, _) => const SizedBox(height: 2),
                itemBuilder: (_, i) => BeatmapItem(
                  beatmap: group[i],
                  onGameplayRequest: onGameplayRequest,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BeatmapItem extends ConsumerWidget {
  @Deprecated("Replace")
  const BeatmapItem({
    super.key,
    required this.beatmap,
    required this.onGameplayRequest,
  });

  final Beatmap beatmap;
  final VoidCallback onGameplayRequest;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.read(audioProvider.notifier);

    final current = ref.watch(audioProvider);

    final selected = current != null ? current == beatmap : false;

    return TweenAnimationBuilder(
      tween: Tween(end: selected ? 1.0 : 0.0),
      curve: Curves.easeOut,
      duration: Durations.short3,
      builder: (_, t, child) => Transform.translate(
        offset: Offset(36 * (1 - t) + 4, 0),
        child: child,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Color.lerp(beatmap.colors.first, Colors.black, .25),
          borderRadius: .circular(4),
        ),
        child: InkWell(
          onTap: () async {
            if (selected) return onGameplayRequest();

            await audio.preview(beatmap);
          },
          mouseCursor: SystemMouseCursors.none,
          child: Row(
            children: [
              const Padding(
                padding: .all(6),
                child: Icon(
                  Icons.radio_button_checked_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              Expanded(
                child: AnimatedContainer(
                  curve: Curves.easeOut,
                  duration: Durations.short3,
                  margin: selected ? const .all(1) : .zero,
                  decoration: BoxDecoration(
                    color: Color.lerp(beatmap.colors.first, Colors.black, .5),
                    borderRadius: .circular(4),
                  ),
                  padding: const .all(6),
                  child: Column(
                    spacing: 2,
                    crossAxisAlignment: .stretch,
                    children: [
                      Text(
                        "${beatmap.info.version} mapped by ${beatmap.info.creator}",
                        maxLines: 1,
                        overflow: .ellipsis,
                        style: const TextStyle(fontSize: 6, height: 1),
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: .circular(4),
                            ),
                            padding: const .fromLTRB(4, 1, 4, 1),
                            child: Text(
                              "0.0",
                              style: TextStyle(
                                height: 1,
                                fontSize: 6,
                                fontWeight: .bold,
                                color: SkewedBox.contrastColor(Colors.grey),
                              ),
                            ),
                          ),
                        ],
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
