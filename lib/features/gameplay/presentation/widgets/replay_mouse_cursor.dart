import 'dart:ui';

import 'package:flosu/core/assets.dart';
import 'package:flosu/core/enums.dart';
import 'package:flosu/features/gameplay/domain/gameplay_data.dart';
import 'package:flosu/features/audio/data/audio_provider.dart';
import 'package:flosu/shared/router.dart';
import 'package:flosu/features/settings/domain/settings.dart';
import 'package:flosu/logic/services/game_loop.dart';
import 'package:flosu/logic/services/logger.dart';
import 'package:flosu/features/gameplay/presentation/painters/gameplay.dart';
import 'package:flutter/material.dart' hide PointerEvent, Image;
import 'package:flutter/services.dart' hide PointerEvent;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReplayMouseCursor extends ConsumerStatefulWidget {
  const ReplayMouseCursor({super.key});

  @override
  ConsumerState<ReplayMouseCursor> createState() => _ReplayMouseCursorState();
}

class _ReplayMouseCursorState extends ConsumerState<ReplayMouseCursor> {
  final ScopedLogger _logger = Logger.requestLogger("ReplayMouseCursor");
  final _position = ValueNotifier<int>(0);

  late final List<Offset> _framePos;
  late final List<int> _frameTimes;

  Image? _mouseImage;

  @override
  void initState() {
    _instantiateCursorImage();
    _getReplayFrames();

    ref.read(gameLoopService).subscribe(TickerPhase.visual, _onTick);
    super.initState();
  }

  @override
  void dispose() {
    globalRef.read(gameLoopService).unsubscribe(TickerPhase.visual, _onTick);
    _logger.dispose();
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
      _logger.error("Error loading mouse as a ui.Image: $err");
    }
  }

  void _getReplayFrames() {
    final frames = ref.read(gameplayDataProvider).replay?.frames ?? [];

    _frameTimes = frames.map((it) => it.time).toList();
    _framePos = frames.map((it) => it.pos).toList();
  }

  void _onTick(_) {
    final position = ref.read(audioProvider.notifier).positionInMs;

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
