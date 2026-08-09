import 'package:flosu/core/extensions/ui.dart';
import 'package:flosu/shared/domain/beatmap/beatmap_selector.dart';
import 'package:flosu/shared/domain/replay/replay_selector.dart';
import 'package:flosu/features/song_select/presentation/widgets/beatmap_info.dart';
import 'package:flosu/shared/widgets/actions_bar.dart';
import 'package:flosu/shared/widgets/skewed_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/shared/layout/animatable_page.dart';
import 'package:flosu/shared/widgets/skewed_button_line.dart';

import '../../../shared/input.dart';

/// Displays the summary screen after a play session ends.
///
/// Shows the song title, grade, score, accuracy, combo, hit counts (300/100/50/
/// miss), and the active mods. If a replay is loaded, provides a button to
/// re-watch it. On exit, clears the session data via [GameplayService.clearAll]
/// unless a replay is being reused.
class ResultsPage extends AnimatablePage {
  const ResultsPage({super.key, required super.uri});

  @override
  ConsumerState<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends AnimatablePageState<ResultsPage>
    with KeyboardHandler {
  bool _enableGrade = false;

  //This is meant for prevent losing replay data while going to gameplay page
  bool _reuseReplay = false;

  @override
  dispose() {
    if (!_reuseReplay) {}

    super.dispose();
  }

  @override
  bool input() {
    if (!keyboard.pressed) return false;

    switch (keyboard.key) {
      case .escape:
        _goBack();
        return true;
      case .backslash:
        _replay();
        return true;
      default:
        return false;
    }
  }

  void _showGrade() {
    if (mounted) setState(() => _enableGrade = true);
  }

  void _goBack() {
    if (mounted) context.go("/songs");
  }

  void _replay() {
    _reuseReplay = true;
    context.go("/load");
  }

  @override
  Widget buildPage(BuildContext context) {
    final beatmap = ref.read(beatmapSelector);
    final replay = ref.read(replaySelector);

    final mods = replay?.mods ?? {};

    assert(
      beatmap != null && replay != null,
      "Both beatmap and replay must be selected",
    );

    return Stack(
      alignment: .bottomCenter,
      children: [
        // Stats
        if (beatmap != null)
          TweenAnimationBuilder(
            tween: Tween(begin: 0.0, end: t >= 0.5 ? 1.0 : 0.0),
            duration: Durations.long1,
            curve: Curves.fastOutSlowIn,
            child: Padding(
              padding: const .only(bottom: 32),
              child: Center(
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisSize: .min,
                  spacing: 4,
                  children: [
                    Align(
                      alignment: .centerLeft,
                      child: SizedBox(
                        width: context.screenScaled.width * 0.4,
                        child: BeatmapInfo(
                          beatmap: beatmap,
                          difficulty: beatmap.difficulty,
                          compactView: true,
                        ),
                      ),
                    ),

                    // Score count
                    SkewedBox(
                      offset: const Offset(-24, 0),
                      decoration: BoxDecoration(
                        color: AppColors.container.withValues(alpha: .75),
                      ),
                      padding: const .fromLTRB(36, 0, 12, 8),
                      child: SizedBox(
                        width: 296,
                        child: Text(
                          "${replay!.score}",
                          textAlign: .end,
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: .w400,
                            height: 1,
                          ),
                        ),
                      ),
                    ),

                    Row(
                      spacing: 4,
                      children: [
                        // Accuracy count
                        // This container is translated
                        SkewedBox(
                          offset: const Offset(-24, 0),
                          decoration: BoxDecoration(
                            color: AppColors.container.withValues(alpha: .875),
                          ),
                          padding: const .fromLTRB(60, 0, 4, 2),
                          child: SizedBox(
                            width: 96,
                            child: Column(
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween(
                                    begin: 0.0,
                                    end: replay.accuracy,
                                  ),
                                  curve: Curves.fastOutSlowIn,
                                  duration: Durations.extralong4,
                                  builder: (_, t, _) => Text(
                                    "${(t * 100).toStringAsFixed(2)}%",
                                    style: const TextStyle(
                                      fontWeight: .w400,
                                      height: 1,
                                    ),
                                  ),
                                ),
                                const Text(
                                  "Accuracy",
                                  style: TextStyle(
                                    fontSize: 7,
                                    fontWeight: .bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Combo count
                        SkewedBox(
                          offset: const Offset(-24, 0),
                          decoration: BoxDecoration(
                            color: AppColors.container.withValues(alpha: .875),
                          ),
                          padding: const .fromLTRB(4, 0, 4, 2),
                          child: SizedBox(
                            width: 80,
                            child: Column(
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween(
                                    begin: 0.0,
                                    end: replay.maxCombo.toDouble(),
                                  ),
                                  curve: Curves.fastOutSlowIn,
                                  duration: Durations.extralong4,
                                  builder: (_, t, _) => Text(
                                    "${t.round()}",
                                    style: const TextStyle(
                                      fontWeight: .w400,
                                      height: 1,
                                    ),
                                  ),
                                ),
                                const Text(
                                  "Combo",
                                  style: TextStyle(
                                    fontSize: 7,
                                    fontWeight: .bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // PP count
                        SkewedBox(
                          offset: const Offset(-24, 0),
                          decoration: BoxDecoration(
                            color: AppColors.container.withValues(alpha: .875),
                          ),
                          padding: const .fromLTRB(4, 0, 4, 2),
                          child: SizedBox(
                            width: 80,
                            child: Column(
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 0.0),
                                  curve: Curves.fastOutSlowIn,
                                  duration: Durations.extralong4,
                                  builder: (_, t, _) => Text(
                                    "${t.round()}",
                                    style: const TextStyle(
                                      fontWeight: .w400,
                                      height: 1,
                                    ),
                                  ),
                                ),
                                const Text(
                                  "PP",
                                  style: TextStyle(
                                    fontSize: 7,
                                    fontWeight: .bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Hit counts
                    Row(
                      spacing: 4,
                      children: [
                        // Greats count
                        // This container is translated
                        SkewedBox(
                          offset: const Offset(-24, 0),
                          decoration: const BoxDecoration(
                            color: AppColors.container,
                          ),
                          padding: const .fromLTRB(42, 0, 4, 2),
                          child: SizedBox(
                            width: 64,
                            child: Column(
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween(
                                    begin: 0.0,
                                    end: replay.stats.greats.toDouble(),
                                  ),
                                  curve: Curves.fastOutSlowIn,
                                  duration: Durations.extralong4,
                                  builder: (_, t, _) => Text(
                                    "${t.round()}",
                                    style: const TextStyle(
                                      fontWeight: .w400,
                                      height: 1,
                                    ),
                                  ),
                                ),
                                const Text(
                                  "Great",
                                  style: TextStyle(
                                    fontSize: 7,
                                    fontWeight: .bold,
                                    color: AppColors.lightBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Ok's count
                        SkewedBox(
                          offset: const Offset(-24, 0),
                          decoration: const BoxDecoration(
                            color: AppColors.container,
                          ),
                          padding: const .fromLTRB(4, 0, 4, 2),
                          child: SizedBox(
                            width: 64,
                            child: Column(
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween(
                                    begin: 0.0,
                                    end: replay.stats.oks.toDouble(),
                                  ),
                                  curve: Curves.fastOutSlowIn,
                                  duration: Durations.extralong4,
                                  builder: (_, t, _) => Text(
                                    "${t.round()}",
                                    style: const TextStyle(
                                      fontWeight: .w400,
                                      height: 1,
                                    ),
                                  ),
                                ),
                                const Text(
                                  "Ok",
                                  style: TextStyle(
                                    fontSize: 7,
                                    fontWeight: .bold,
                                    color: AppColors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Mehs count
                        SkewedBox(
                          offset: const Offset(-24, 0),
                          decoration: const BoxDecoration(
                            color: AppColors.container,
                          ),
                          padding: const .fromLTRB(4, 0, 4, 2),
                          child: SizedBox(
                            width: 64,
                            child: Column(
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween(
                                    begin: 0.0,
                                    end: replay.stats.mehs.toDouble(),
                                  ),
                                  curve: Curves.fastOutSlowIn,
                                  duration: Durations.extralong4,
                                  builder: (_, t, _) => Text(
                                    "${t.round()}",
                                    style: const TextStyle(
                                      fontWeight: .w400,
                                      height: 1,
                                    ),
                                  ),
                                ),
                                const Text(
                                  "Meh",
                                  style: TextStyle(
                                    fontSize: 7,
                                    fontWeight: .bold,
                                    color: AppColors.yellow,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Misses count
                        SkewedBox(
                          offset: const Offset(-24, 0),
                          decoration: const BoxDecoration(
                            color: AppColors.container,
                          ),
                          padding: const .fromLTRB(4, 0, 4, 2),
                          child: SizedBox(
                            width: 64,
                            child: Column(
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween(
                                    begin: 0.0,
                                    end: replay.stats.misses.toDouble(),
                                  ),
                                  curve: Curves.fastOutSlowIn,
                                  duration: Durations.extralong4,
                                  builder: (_, t, _) => Text(
                                    "${t.round()}",
                                    style: const TextStyle(
                                      fontWeight: .w400,
                                      height: 1,
                                    ),
                                  ),
                                ),
                                const Text(
                                  "Miss",
                                  style: TextStyle(
                                    fontSize: 7,
                                    fontWeight: .bold,
                                    color: AppColors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            builder: (_, t, child) => FractionalTranslation(
              translation: Offset(-1 + t, 0),
              child: Opacity(opacity: t, child: child),
            ),
          ),

        //Grade
        Align(
          alignment: .centerRight,
          child: Container(
            width: 292,
            height: 260,
            margin: const .only(bottom: 32),
            padding: const .fromLTRB(8, 8, 40, 8),
            decoration: const BoxDecoration(
              borderRadius: .only(
                bottomLeft: .circular(160),
                topLeft: .circular(160),
              ),
              color: Colors.black38,
            ),
            child: Stack(
              fit: .expand,
              children: [
                Container(
                  alignment: .center,
                  margin: const .only(bottom: 16),
                  child: TweenAnimationBuilder(
                    curve: Curves.fastOutSlowIn,
                    duration: Durations.long2,
                    tween: Tween(end: _enableGrade ? 1.0 : 0.0),
                    builder: (_, t, _) => Transform.scale(
                      scale: 1.125 - (t / 8),
                      child: Text(
                        replay!.rank.name.toUpperCase(),
                        style: TextStyle(
                          shadows: [
                            Shadow(
                              color: replay.rank.color.withValues(alpha: t),
                              blurRadius: 6,
                            ),
                          ],
                          letterSpacing: -6,
                          fontWeight: .bold,
                          fontSize: 128,
                          height: 1,
                          color: Colors.white.withValues(alpha: t),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const .all(8),
                  child: TweenAnimationBuilder(
                    curve: Curves.easeOut,
                    tween: Tween(begin: 0.0, end: replay!.accuracy),
                    duration: const Duration(seconds: 1, milliseconds: 500),
                    onEnd: () => _showGrade(),
                    builder: (_, t, _) => CircularProgressIndicator(
                      strokeWidth: 12,
                      strokeCap: .round,
                      value: t * 0.975,
                      backgroundColor: AppColors.container,
                      color: Color.lerp(Colors.white, replay.rank.color, t),
                      // ignore: deprecated_member_use
                      /* year2023: false, */
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        ActionsBar(
          onBack: () => context.go("/songs"),
          actionsPadding: const .only(left: 24),
          actionsSpacing: 4,
          actions: [
            const SkewedButtonLine(
              color: AppColors.lightBlue,
              icon: Icon(Icons.download_outlined),
              label: Text("Download"),
            ),
            const SkewedButtonLine(
              color: AppColors.pink,
              icon: Icon(Icons.camera_alt_outlined),
              label: Text("Screenshot"),
            ),
            const SkewedButtonLine(
              color: AppColors.purple,
              icon: Icon(Icons.auto_graph),
              label: Text("More info"),
            ),
          ],
          trailing: replay != null
              ? SkewedBox(
                  decoration: BoxDecoration(
                    borderRadius: .circular(4),
                    color: AppColors.purple,
                  ),
                  useGradientBorder: true,
                  margin: const .fromLTRB(0, 12, 18, 12),
                  padding: const .symmetric(vertical: 9, horizontal: 33),
                  onTap: () {
                    _reuseReplay = true;
                    context.go("/load");
                  },
                  child: const Row(
                    spacing: 4,
                    children: [
                      Icon(Icons.play_arrow_rounded, size: 8),
                      Text("Watch replay", style: TextStyle(fontSize: 8)),
                    ],
                  ),
                )
              : null,
        ),
      ],
    );
  }
}
