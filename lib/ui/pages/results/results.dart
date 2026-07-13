import 'package:flosu/logic/providers/gameplay_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/ui/widgets/song_select/mod_icon.dart';
import 'package:flosu/logic/providers/router.dart';
import 'package:flosu/ui/shared/animatable_page.dart';
import 'package:flosu/ui/widgets/common/skewed_box.dart';
import 'package:flosu/ui/widgets/common/skewed_button_line.dart';

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

class _ResultsPageState extends AnimatablePageState<ResultsPage> {
  bool _enableGrade = false;

  //This is meant for prevent losing replay data while going to gameplay page
  bool _reuseReplay = false;

  void _showGrade() {
    if (mounted) setState(() => _enableGrade = true);
  }

  @override
  dispose() {
    if (!_reuseReplay) {
      Future.microtask(
        () => globalRef.read(gameplayDataProvider.notifier).clearAll(),
      );
    }

    super.dispose();
  }

  @override
  Widget buildPage(BuildContext context, double animProgress) {
    final details = ref.watch(gameplayDataProvider);
    final mods = details.mods;

    return Stack(
      alignment: .bottomCenter,
      children: [
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
                    curve: Curves.easeInCubic,
                    duration: Durations.short2,
                    tween: Tween(end: _enableGrade ? 1.0 : 0.0),
                    builder: (_, t, _) => Text(
                      ":D",
                      style: TextStyle(
                        shadows: const [
                          Shadow(
                            offset: Offset(4, 4),
                            color: Colors.black38,
                            blurRadius: 48,
                          ),
                        ],
                        letterSpacing: -6,
                        fontWeight: .bold,
                        fontSize: 128,
                        height: 1,
                        color: Colors.white.withAlpha((255 * t).round()),
                      ),
                    ),
                  ),
                ),
                TweenAnimationBuilder(
                  curve: Curves.easeOut,
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(seconds: 1, milliseconds: 500),
                  onEnd: () => _showGrade(),
                  builder: (_, t, _) => CircularProgressIndicator(
                    strokeWidth: 12,
                    value: t,
                    color: Color.lerp(
                      const Color(0xff7cf5fe),
                      const Color(0xffb8feaa),
                      t,
                    ),
                    // ignore: deprecated_member_use
                    year2023: false,
                  ),
                ),
              ],
            ),
          ),
        ),

        //Stats
        Container(
          alignment: .centerLeft,
          margin: const .only(bottom: 32),
          child: Column(
            crossAxisAlignment: .start,
            mainAxisSize: .min,
            spacing: 4,
            children: [
              //Beatmap info
              SkewedBox(
                width: 370,
                offset: const Offset(-24, 0),
                useGradientBorder: true,
                decoration: const BoxDecoration(color: AppColors.background),
                child: Column(
                  crossAxisAlignment: .stretch,
                  mainAxisSize: .min,
                  children: [
                    SkewedBox(
                      offset: const Offset(2, 0),
                      decoration: const BoxDecoration(
                        color: AppColors.container,
                      ),
                      child: Padding(
                        padding: const .fromLTRB(104, 8, 8, 8),
                        child: Column(
                          crossAxisAlignment: .stretch,
                          mainAxisSize: .min,
                          children: [
                            Text(
                              "${details.metadata?.info.title}",
                              maxLines: 2,
                              overflow: .ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: .w700,
                                height: 1,
                              ),
                            ),
                            Text(
                              "${details.metadata?.info.artist}",
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
                        "${details.metadata?.info.version} mapped by ${details.metadata?.info.creator}",
                        maxLines: 1,
                        overflow: .ellipsis,
                        style: const TextStyle(fontSize: 8, height: 1),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              //Score
              SkewedBox(
                width: 352,
                offset: const Offset(-24, 0),
                padding: const .fromLTRB(0, 0, 16, 8),
                decoration: BoxDecoration(
                  color: AppColors.background.withAlpha(160),
                ),
                child: Row(
                  mainAxisAlignment: .end,
                  mainAxisSize: .min,
                  spacing: 4,
                  children: [
                    TweenAnimationBuilder(
                      tween: Tween(
                        begin: 0.0,
                        end: details.replay?.hitStats.score ?? 0,
                      ),
                      duration: Durations.extralong4,
                      curve: Curves.easeOut,
                      builder: (_, t, _) => Text(
                        "${t.round()}",
                        style: const TextStyle(
                          fontWeight: .w300,
                          fontSize: 48,
                          height: 1,
                        ),
                      ),
                    ),

                    /*  Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xffb8feaa),
                      size: 48,
                    ), */
                  ],
                ),
              ),

              //Acc., combo and PP
              Row(
                spacing: 2,
                children: [
                  const SizedBox(width: 56),
                  const SkewedBox(
                    width: 80,
                    padding: .all(6),
                    useGradientBorder: true,
                    decoration: BoxDecoration(color: AppColors.container),
                    child: Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        Text(
                          "ACCURACY",
                          style: TextStyle(fontSize: 6, height: 1),
                        ),
                        Text(
                          "100.00%",
                          style: TextStyle(fontSize: 14, height: 1),
                        ),
                      ],
                    ),
                  ),
                  SkewedBox(
                    width: 80,
                    padding: const .all(6),
                    useGradientBorder: true,
                    decoration: const BoxDecoration(color: AppColors.container),
                    child: Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        const Text(
                          "COMBO",
                          style: TextStyle(fontSize: 6, height: 1),
                        ),
                        Text(
                          "${details.replay?.hitStats.maxCombo ?? 0}x",
                          style: const TextStyle(fontSize: 14, height: 1),
                        ),
                      ],
                    ),
                  ),
                  const SkewedBox(
                    width: 80,
                    padding: .all(6),
                    useGradientBorder: true,
                    decoration: BoxDecoration(color: AppColors.container),
                    child: Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        Text("PP", style: TextStyle(fontSize: 6, height: 1)),
                        Text("", style: TextStyle(fontSize: 14, height: 1)),
                      ],
                    ),
                  ),
                ],
              ),

              //Hits
              Row(
                spacing: 2,
                children: [
                  const SizedBox(width: 50),
                  SkewedBox(
                    width: 59,
                    padding: const .all(6),
                    useGradientBorder: true,
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        AppColors.lightBlue,
                        Colors.black,
                        2 / 3,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        const Text(
                          "300",
                          style: TextStyle(fontSize: 6, height: 1),
                        ),
                        TweenAnimationBuilder(
                          tween: Tween(
                            begin: 0.0,
                            end: details.replay?.hitStats.greats ?? 0,
                          ),
                          duration: Durations.extralong4,
                          curve: Curves.easeOut,
                          builder: (_, t, _) => Text(
                            "${t.round()}",
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1,
                              color: AppColors.lightBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SkewedBox(
                    width: 59,
                    padding: const .all(6),
                    useGradientBorder: true,
                    decoration: BoxDecoration(
                      color: Color.lerp(AppColors.green, Colors.black, 2 / 3),
                    ),
                    child: Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        const Text(
                          "100",
                          style: TextStyle(fontSize: 6, height: 1),
                        ),
                        TweenAnimationBuilder(
                          tween: Tween(
                            begin: 0.0,
                            end: details.replay?.hitStats.oks ?? 0,
                          ),
                          duration: Durations.extralong4,
                          curve: Curves.easeOut,
                          builder: (_, t, _) => Text(
                            "${t.round()}",
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1,
                              color: AppColors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SkewedBox(
                    width: 59,
                    padding: const .all(6),
                    useGradientBorder: true,
                    decoration: BoxDecoration(
                      color: Color.lerp(AppColors.yellow, Colors.black, 2 / 3),
                    ),
                    child: Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        const Text(
                          "50",
                          style: TextStyle(fontSize: 6, height: 1),
                        ),
                        TweenAnimationBuilder(
                          tween: Tween(
                            begin: 0.0,
                            end: details.replay?.hitStats.mehs ?? 0,
                          ),
                          duration: Durations.extralong4,
                          curve: Curves.easeOut,
                          builder: (_, t, _) => Text(
                            "${t.round()}",
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1,
                              color: AppColors.yellow,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SkewedBox(
                    width: 59,
                    padding: const .all(6),
                    useGradientBorder: true,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.red, width: 1),
                      color: Color.lerp(AppColors.red, Colors.black, 2 / 3),
                    ),
                    child: Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        const Text(
                          "MISS",
                          style: TextStyle(fontSize: 6, height: 1),
                        ),
                        TweenAnimationBuilder(
                          tween: Tween(
                            begin: 0.0,
                            end: details.replay?.hitStats.misses ?? 0,
                          ),
                          duration: Durations.extralong4,
                          curve: Curves.easeOut,
                          builder: (_, t, _) => Text(
                            "${t.round()}",
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1,
                              color: AppColors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              //Slider and spinner stats
              const Row(
                spacing: 2,
                children: [
                  SizedBox(width: 40),
                  SkewedBox(
                    width: 80,
                    padding: .all(6),
                    useGradientBorder: true,
                    decoration: BoxDecoration(color: AppColors.container),
                    child: Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        Text(
                          "SLIDER TICK",
                          style: TextStyle(fontSize: 6, height: 1),
                        ),
                        Text("", style: TextStyle(fontSize: 16, height: 1)),
                      ],
                    ),
                  ),
                  SkewedBox(
                    width: 80,
                    padding: .all(6),
                    useGradientBorder: true,
                    decoration: BoxDecoration(color: AppColors.container),
                    child: Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        Text(
                          "SLIDER END",
                          style: TextStyle(fontSize: 6, height: 1),
                        ),
                        Text("", style: TextStyle(fontSize: 16, height: 1)),
                      ],
                    ),
                  ),
                  SkewedBox(
                    width: 80,
                    padding: .all(6),
                    useGradientBorder: true,
                    decoration: BoxDecoration(color: AppColors.container),
                    child: Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        Text(
                          "SPINNER BONUS",
                          style: TextStyle(fontSize: 6, height: 1),
                        ),
                        Text("", style: TextStyle(fontSize: 16, height: 1)),
                      ],
                    ),
                  ),
                ],
              ),

              //Mods
              if (mods.isNotEmpty)
                Container(
                  width: 244,
                  margin: const .only(top: 16, left: 32),
                  child: Row(
                    spacing: 2,
                    children: [
                      for (final mod in mods)
                        ModIcon(mod: mod, selected: true, size: 20),
                    ],
                  ),
                ),
            ],
          ),
        ),

        Container(color: AppColors.background, height: 32),
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
              onTap: () => context.go("/songs"),
              child: const Text("Back", style: TextStyle(fontSize: 8)),
            ),
            const SizedBox(width: 16),
            SkewedButtonLine(
              color: AppColors.green,
              icon: const Icon(Icons.replay),
              onTap: details.metadata != null
                  ? () {
                      _reuseReplay = true;
                      context.go("/load");
                    }
                  : null,
              label: const Text("Watch replay"),
            ),
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
        ),
      ],
    );
  }
}
