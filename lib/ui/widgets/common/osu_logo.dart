import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flosu/logic/providers/audio.dart';
import 'package:flosu/models/beatmap/beatmap.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/logic/providers/gameplay_service.dart';

// ignore: constant_identifier_names
const LOGO_SIZE = 512.0;

class OsuLogo extends ConsumerStatefulWidget {
  const OsuLogo({super.key, this.scale = 1, this.onTap});
  final double scale;
  final VoidCallback? onTap;

  @override
  ConsumerState<OsuLogo> createState() => _OsuLogoState();
}

class _OsuLogoState extends ConsumerState<OsuLogo> {
  final _key = GlobalKey();

  int _beats = 0;
  double _beatLength = 60;
  Timer? _beatTimer;

  @override
  initState() {
    ref.listenManual(
      gameplayService,
      (_, n) => _getTiming(),
      fireImmediately: true,
    );
    super.initState();
  }

  @override
  dispose() {
    _beatTimer?.cancel();
    super.dispose();
  }

  void _getTiming() {
    final positionInMs = ref.read(audioProvider.notifier).positionInMs;

    final current = ref.read(gameplayService).beatmap?.timing;

    const default_ = UTimingPoint(time: 0, beatLength: 1000, meter: 4);

    final currentTiming = (current == null || current.isEmpty)
        //Select base point if empty
        ? default_
        :
          //Select first point after time
          current.reversed
                  .whereType<UTimingPoint>()
                  .where((t) => positionInMs > t.time)
                  .firstOrNull ??
              //Select first point
              current.whereType<UTimingPoint>().firstOrNull ??
              //Select base point if not found
              default_;

    if (currentTiming.beatLength != _beatLength) {
      final length = max(currentTiming.beatLength, 0.001);
      _beatLength = length;

      _beatTimer?.cancel();
      _beatTimer = Timer.periodic(
        Duration(
          milliseconds: length.round(),
          microseconds: (length % 1000).round(),
        ),
        (_) {
          _beats++;
          if (mounted) setState(() {});
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "Osu logo",
      child: TweenAnimationBuilder(
        tween: Tween(end: _beats.toDouble()),
        duration: Duration(
          milliseconds: _beatLength.round(),
          microseconds: (_beatLength % 1000).round(),
        ),
        curve: Curves.easeOut,
        child: Stack(
          clipBehavior: .none,
          alignment: .center,
          children: [
            Material(
              type: .circle,
              color: Colors.pink.shade300,
              child: InkWell(
                mouseCursor: SystemMouseCursors.none,
                customBorder: const CircleBorder(),
                onTap: widget.onTap,
                child: const Center(),
              ),
            ),
            IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  margin: const .all(8),
                  decoration: BoxDecoration(
                    shape: .circle,
                    border: .all(color: Colors.black12, width: 32),
                  ),
                  child: const Center(),
                ),
              ),
            ),

            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  shape: .circle,
                  border: .all(color: Colors.white, width: 32),
                ),
                padding: const .fromLTRB(64, 64, 96, 64),
                alignment: const Alignment(-0.15, 0),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(Colors.pink.shade50, .srcIn),
                  child: const DecoratedBox(
                    decoration: FlutterLogoDecoration(),
                    child: SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ],
        ),
        builder: (_, t, child) => Transform.scale(
          filterQuality: .low,
          scale: 1 - (0.025 * (t % 1)),
          child: SizedBox.square(
            key: _key,
            dimension: LOGO_SIZE * widget.scale,
            child: FittedBox(
              fit: .cover,
              alignment: .bottomRight,
              child: Container(
                height: LOGO_SIZE,
                width: LOGO_SIZE,
                decoration: BoxDecoration(
                  shape: .circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.pink.withAlpha(
                        (64 * (1 - (t % 1))).round(),
                      ),
                      spreadRadius: (t % 1) * 64,
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
