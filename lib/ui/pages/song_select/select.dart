import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flosu/logic/providers/library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide PointerEvent;
import 'package:flutter/services.dart' hide PointerEvent;
import 'package:go_router/go_router.dart';
import 'package:flosu/logic/providers/audio.dart';
import 'package:flosu/logic/providers/input.dart';
import 'package:flosu/models/beatmap/beatmap.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/core/extensions.dart';
import 'package:flosu/logic/gameplay_service.dart';
import 'package:flosu/models/inputs/inputs.dart';
import 'package:flosu/logic/providers/router.dart';
import 'package:flosu/ui/shared/animatable_page.dart';
import 'package:flosu/ui/widgets/beatmap/current_beatmap_info.dart';
import 'package:flosu/ui/widgets/common/skewed_box.dart';
import 'package:flosu/ui/widgets/common/osu_logo.dart';
import 'package:flosu/ui/widgets/common/skewed_button_line.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class SongSelectPage extends AnimatablePage {
  const SongSelectPage({super.key, required super.uri});

  @override
  AnimatablePageState<SongSelectPage> createState() => _SongSelectPageState();
}

class _SongSelectPageState extends AnimatablePageState<SongSelectPage> {
  final _scrollController = ItemScrollController();
  final _itemListener = ItemPositionsListener.create();
  final _sCon = TextEditingController();

  Set<LogicalKeyboardKey> _lastKeys = {};
  late int _currentIdx = _getCurrentIndex() ?? -1;
  Timer? _updateTimer;
  List<ItemPosition> _itemPositions = [];

  @override
  initState() {
    _itemListener.itemPositions.addListener(_updateItemPositions);
    ref.read(inputProvider.notifier).addInmediateHandler(_onInput);
    super.initState();
  }

  @override
  dispose() {
    _lastKeys.clear();
    _updateTimer?.cancel();
    _itemListener.itemPositions.removeListener(_updateItemPositions);

    //Widget is unsafe, calling from root navigator
    globalRef.read(inputProvider.notifier).removeInmediateHandler(_onInput);
    _sCon.dispose();
    super.dispose();
  }

  void _updateItemPositions() {
    _itemPositions = _itemListener.itemPositions.value.toList();
    if (mounted) setState(() {});
  }

  int? _getCurrentIndex() {
    final beatmap = ref.read(gameplayService).beatmap;

    if (beatmap == null) return null;

    final groupIndex = ref
        .read(libraryProvider)
        .asGroups
        .indexWhere((group) => group.any((bm) => bm == beatmap));

    return groupIndex != -1 ? groupIndex : 0;
  }

  void _onInput(Set<LogicalKeyboardKey> keys, PointerEvent? pointer) {
    if (setEquals(_lastKeys, keys)) return;

    //If F1 pressed and keys changed, open mods
    if (keys.changedAndPressed("F1", _lastKeys)) {
      if (mounted) context.go("/songs/mods");
    }

    //If F2 pressed and keys changed, play random song
    if (keys.changedAndPressed("F2", _lastKeys)) {
      _playRandom();
    }

    //If F3 pressed and keys changed, open replay window
    if (keys.changedAndPressed("F3", _lastKeys)) {
      ref.read(gameplayService.notifier).loadReplay();
    }

    _lastKeys = keys.toSet();
  }

  void _setBeatmap(Beatmap beatmap, [bool skipScroll = false]) async {
    final groupIndex = ref
        .read(libraryProvider)
        .asGroups
        .indexWhere((group) => group.any((bm) => bm == beatmap));

    if (groupIndex != -1) {
      if (!skipScroll) _scrollTo(groupIndex);
      if (mounted) setState(() => _currentIdx = groupIndex);
    }

    await ref.read(audioProvider.notifier).preview(beatmap);
  }

  void _playRandom() async {
    final bm = ref.read(libraryProvider.notifier).getRandom();
    if (bm != null) _setBeatmap(bm);
  }

  Future<void> _scrollTo(int index) async {
    /* for (int i = 1; i < 5; i++) {
      Future.delayed(
        Durations.short1 * i,
        () => */
    _scrollController.isAttached
        ? _scrollController.scrollTo(
            index: index,
            alignment: .4,
            duration: Durations.short2,
            curve: Curves.easeInOut,
          )
        : null /* ,
      ) */;
    // }
  }

  @override
  Widget buildPage(BuildContext context, double animProgress) {
    final matches = ref.watch(libraryProvider).asGroups;

    return Stack(
      fit: .expand,
      children: [
        Stack(
          alignment: .bottomCenter,
          children: [
            CurrentBeatmapInfo(animProgress: animProgress),

            //Beatmap List
            Positioned(
              top: 0,
              left: context.screenScaled.width / 2,
              width: context.screenScaled.width / 2,
              height: context.screenScaled.height - 60,
              child: Opacity(
                opacity: animProgress,
                child: Column(
                  crossAxisAlignment: .end,
                  children: [
                    SkewedBox(
                      constraints: const BoxConstraints(
                        minWidth: 280,
                        maxWidth: 448,
                      ),
                      width: context.screenScaled.width / 2,
                      offset: const Offset(20, 0),
                      padding: const .all(4),
                      decoration: BoxDecoration(
                        borderRadius: const .only(bottomLeft: .circular(8)),
                        color: Colors.grey.shade900.withAlpha(128),
                      ),
                      child: Column(
                        children: [
                          SkewedBox(
                            decoration: BoxDecoration(
                              borderRadius: .circular(2),
                              color: Colors.grey.shade800,
                            ),
                            margin: const .only(right: 22),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SkewedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: .circular(2),
                                      color: Colors.grey.shade900,
                                    ),
                                    child: TextField(
                                      controller: _sCon,
                                      onChanged: (_) {
                                        if (mounted) setState(() {});
                                      },
                                      style: const TextStyle(fontSize: 10),

                                      decoration: InputDecoration(
                                        isCollapsed: true,
                                        contentPadding: const .only(top: 6),
                                        constraints: const BoxConstraints(
                                          maxHeight: 30,
                                        ),
                                        helper: Transform.translate(
                                          offset: const Offset(0, -2),
                                          child: Text(
                                            "${matches.length} matches",
                                            style: const TextStyle(
                                              fontSize: 6,
                                              color: Colors.amber,
                                            ),
                                          ),
                                        ),
                                        hintText: "search...",

                                        hintStyle: const TextStyle(
                                          fontSize: 10,
                                        ),

                                        border: const OutlineInputBorder(
                                          borderSide: .none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SkewedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: .circular(2),
                                  ),
                                  onTap: () {},
                                  padding: const .fromLTRB(6, 8, 6, 8),
                                  child: const Icon(Icons.search, size: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: .centerRight,
                        child: ScrollConfiguration(
                          behavior: const MaterialScrollBehavior().copyWith(
                            dragDevices: PointerDeviceKind.values.toSet(),
                          ),
                          child: MouseRegion(
                            onExit: (_) => _scrollTo(_getCurrentIndex() ?? 0),
                            child: ScrollablePositionedList.builder(
                              initialScrollIndex: _getCurrentIndex() ?? 0,
                              initialAlignment: .5,
                              itemScrollController: _scrollController,
                              itemPositionsListener: _itemListener,
                              padding: .symmetric(
                                vertical:
                                    (context.screenScaled.height - 60) * .4,
                              ),
                              physics: const BouncingScrollPhysics(),
                              itemCount: matches.length,
                              itemBuilder: (_, idx) {
                                final first = matches[idx].first;

                                final selected = idx == _currentIdx;

                                // Buscamos la posición de este ítem específico
                                double itemLeadingEdge = 0.0;
                                double itemTrailingEdge = 0.0;

                                final position = _itemPositions
                                    .where((p) => p.index == idx)
                                    .toList();

                                if (position.isNotEmpty) {
                                  itemLeadingEdge =
                                      position.first.itemLeadingEdge;
                                  itemTrailingEdge =
                                      position.first.itemTrailingEdge;
                                }

                                double itemCenter =
                                    (itemLeadingEdge + itemTrailingEdge) / 2;

                                double distanceToCenter = (0.5 - itemCenter)
                                    .abs();

                                // Normalizamos (0.0 en el centro, sube conforme se aleja)
                                double linearFactor = distanceToCenter.clamp(
                                  0.0,
                                  1.0,
                                ); // Multiplicamos por 2 para que el rango sea 0 a 1

                                double curvedFactor = Curves.fastOutSlowIn
                                    .transform(linearFactor);

                                double t = curvedFactor / 6;

                                return FractionalTranslation(
                                  translation: Offset(
                                    t + (1 / 80) + (selected ? 0 : 0.05),
                                    0,
                                  ),
                                  child: Column(
                                    mainAxisSize: .min,
                                    children: [
                                      Container(
                                        margin: const .fromLTRB(36, 4, 4, 0),
                                        width:
                                            (context.screenScaled.width / 2) -
                                            32,
                                        decoration: BoxDecoration(
                                          color: Color.lerp(
                                            first.colors.first,
                                            AppColors.containerHigh,
                                            .5,
                                          ),
                                          borderRadius: const .only(
                                            topLeft: .circular(4),
                                            bottomLeft: .circular(4),
                                          ),
                                        ),
                                        child: InkWell(
                                          mouseCursor: SystemMouseCursors.none,
                                          onTap: () => _setBeatmap(first),
                                          child: Row(
                                            children: [
                                              const Padding(
                                                padding: .all(2),
                                                child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 6,
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  padding: const .all(8),
                                                  decoration: BoxDecoration(
                                                    color: Color.lerp(
                                                      first.colors.first,
                                                      AppColors.container,
                                                      2 / 3,
                                                    ),
                                                    borderRadius: const .only(
                                                      topLeft: .circular(4),
                                                      bottomLeft: .circular(4),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: .min,
                                                    crossAxisAlignment:
                                                        .stretch,
                                                    children: [
                                                      Text(
                                                        first.info.title,
                                                        style: const TextStyle(
                                                          fontWeight: .bold,
                                                          fontSize: 10,
                                                          height: 1,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 1),
                                                      Text(
                                                        first.info.artist,
                                                        style: const TextStyle(
                                                          fontSize: 6,
                                                          height: 1,
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
                                        for (final beatmap in matches[idx])
                                          Container(
                                            margin: const .fromLTRB(
                                              96,
                                              4,
                                              4,
                                              0,
                                            ),
                                            width:
                                                (context.screenScaled.width /
                                                    2) -
                                                96,
                                            decoration: BoxDecoration(
                                              color: Color.lerp(
                                                first.colors.first,
                                                AppColors.containerHigh,
                                                .5,
                                              ),
                                              borderRadius: const .only(
                                                topLeft: .circular(4),
                                                bottomLeft: .circular(4),
                                              ),
                                            ),
                                            child: InkWell(
                                              onTap: () =>
                                                  _setBeatmap(beatmap, true),
                                              mouseCursor:
                                                  SystemMouseCursors.none,
                                              child: Row(
                                                children: [
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Container(
                                                      padding: const .all(6),
                                                      decoration: BoxDecoration(
                                                        color: Color.lerp(
                                                          first.colors.first,
                                                          AppColors.container,
                                                          2 / 3,
                                                        ),
                                                        borderRadius:
                                                            const .only(
                                                              topLeft:
                                                                  .circular(4),
                                                              bottomLeft:
                                                                  .circular(4),
                                                            ),
                                                      ),
                                                      child: Column(
                                                        mainAxisSize: .min,
                                                        crossAxisAlignment:
                                                            .stretch,
                                                        children: [
                                                          Text(
                                                            beatmap
                                                                .info
                                                                .version,
                                                            style:
                                                                const TextStyle(
                                                                  fontWeight:
                                                                      .bold,
                                                                  fontSize: 8,
                                                                  height: 1,
                                                                ),
                                                          ),
                                                          Text(
                                                            beatmap
                                                                .info
                                                                .creator,
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 4,
                                                                  height: 1,
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
                                    ],
                                  ),
                                );
                              },
                              /* itemBuilder: (_,  idx) => ,
                             */
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //Actions
            Container(
              color: AppColors.background.withAlpha(
                (255 * animProgress).round(),
              ),
              height: 32,
            ),
            Row(
              spacing: 4,
              crossAxisAlignment: .end,
              children: [
                SkewedBox(
                  heroTag: "Back button",
                  opacity: animProgress,
                  decoration: BoxDecoration(
                    borderRadius: .circular(4),
                    color: AppColors.fucshia,
                  ),
                  useGradientBorder: true,
                  margin: const .fromLTRB(18, 0, 0, 12),
                  padding: const .symmetric(vertical: 9, horizontal: 33),
                  onTap: () => context.go("/main"),
                  child: const Text("Back", style: TextStyle(fontSize: 8)),
                ),
                const SizedBox(width: 16),
                SkewedButtonLine(
                  offset: Offset(0, 48 * (1 - animProgress)),
                  color: AppColors.green,
                  icon: const Icon(Icons.auto_awesome),
                  onTap: () => context.go("/songs/mods"),
                  label: const Text("Mods"),
                ),
                SkewedButtonLine(
                  offset: Offset(0, 72 * (1 - animProgress)),
                  color: AppColors.lightBlue,
                  icon: const Icon(Icons.shuffle),
                  onTap: _playRandom,
                  label: const Text("Random"),
                ),
                SkewedButtonLine(
                  offset: Offset(0, 96 * (1 - animProgress)),
                  color: AppColors.pink,
                  icon: const Icon(Icons.file_open_outlined),
                  onTap: ref.read(gameplayService.notifier).loadReplay,
                  label: const Text("Open replay"),
                ),
                SkewedButtonLine(
                  offset: Offset(0, 120 * (1 - animProgress)),
                  color: AppColors.purple,
                  icon: const Icon(Icons.settings_outlined),
                  label: const Text("Options"),
                ),
                const Spacer(),
                Padding(
                  padding: const .all(12),
                  child: OsuLogo(
                    scale: (1 / 5) * animProgress,
                    onTap: () => context.go("/load"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
