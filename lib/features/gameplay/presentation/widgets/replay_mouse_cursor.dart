import 'dart:ui';

import 'package:flosu/core/assets.dart';
import 'package:flosu/shared/domain/replay/replay_selector.dart';
import 'package:flosu/shared/logging.dart';
import 'package:flosu/features/settings/domain/settings_provider.dart';
import 'package:flosu/core/engine/game_loop.dart';
import 'package:flosu/features/gameplay/presentation/painters/gameplay.dart';
import 'package:flutter/material.dart' hide PointerEvent, Image;
import 'package:flutter/services.dart' hide PointerEvent;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio/audio.dart';

class ReplayMouseCursor extends ConsumerStatefulWidget {
  const ReplayMouseCursor({super.key});

  @override
  ConsumerState<ReplayMouseCursor> createState() => _ReplayMouseCursorState();
}

class _ReplayMouseCursorState extends ConsumerState<ReplayMouseCursor>
    with Logging, GameLoopListener {
  final _position = ValueNotifier<double>(0);

  late final List<Offset> _framePos;
  late final List<int> _frameTimes;

  Image? _mouseImage;

  @override
  void initState() {
    requestLogger();
    _instantiateCursorImage();
    _getReplayFrames();
    super.initState();
  }

  @override
  void dispose() {
    removeLogger();
    super.dispose();
  }

  void _instantiateCursorImage() async {
    try {
      final data = await rootBundle.load(AppImages.replayCursor);
      final view = Uint8List.view(data.buffer);
      final codec = await instantiateImageCodec(view);
      final frame = await codec.getNextFrame();

      _mouseImage = frame.image;
      if (mounted) setState(() {});
    } catch (err) {
      log("Error loading mouse as a ui.Image: $err", level: .error);
    }
  }

  void _getReplayFrames() {
    final replay = ref.read(replaySelector);

    assert(replay != null, "Replay must be selected to use this widget");

    _frameTimes = replay!.frames.map((it) => it.time).toList();
    _framePos = replay.frames.map((it) => it.position).toList();
  }

  @override
  void process(double delta) {
    final position = ref.read(audioClock);

    if (_position.value == position) return;
    _position.value = position;
  }

  @override
  Widget build(BuildContext context) {
    final cursorTrailEnabled = ref.watch(
      settingsProvider.select((it) => it.cursorTrailEnabled),
    );

    return CustomPaint(
      painter: ReplayMousePainter(
        framePos: _framePos,
        frameTimes: _frameTimes,
        position: _position,
        showTrail: cursorTrailEnabled,
        cursorImage: _mouseImage,
      ),
    );
  }
}
