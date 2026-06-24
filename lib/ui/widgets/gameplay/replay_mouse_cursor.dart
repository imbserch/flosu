import 'dart:ui';

import 'package:flosu/core/extensions.dart';
import 'package:flosu/logic/gameplay_service.dart';
import 'package:flosu/logic/providers/audio.dart';
import 'package:flosu/logic/providers/router.dart';
import 'package:flosu/logic/providers/storage.dart';
import 'package:flosu/logic/services/gameloop.dart';
import 'package:flosu/models/inputs/inputs.dart';
import 'package:flosu/ui/painters/gameplay.dart';
import 'package:flutter/material.dart' hide PointerEvent, Image;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' hide PointerEvent;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReplayMouseCursor extends ConsumerStatefulWidget {
  const ReplayMouseCursor({super.key});

  @override
  ConsumerState<ReplayMouseCursor> createState() => _ReplayMouseCursorState();
}

class _ReplayMouseCursorState extends ConsumerState<ReplayMouseCursor> {
  final _cursorEvents = ValueNotifier<List<ReplayFrameEvent>>([]);
  final _positionEvents = ValueNotifier<int>(0);

  late final _frames = ref.watch(
    gameplayService.select((it) => it.replay?.frames ?? []),
  );

  Image? _mouseImage;

  @override
  void initState() {
    _instantiateCursorImage();

    ref.read(gameLoopService).subscribe(TickerPhase.visual, _onTick);
    super.initState();
  }

  @override
  void dispose() {
    globalRef.read(gameLoopService).subscribe(TickerPhase.visual, _onTick);
    super.dispose();
  }

  void _instantiateCursorImage() async {
    try {
      final data = await rootBundle.load("assets/images/cursor.png");
      final view = Uint8List.view(data.buffer);
      final codec = await instantiateImageCodec(view);
      final frame = await codec.getNextFrame();

      _mouseImage = frame.image;
      if (mounted) setState(() {});
    } catch (err) {
      "Error loading mouse as a ui.Image: $err".log;
    }
  }

  void _onTick(_) {
    //Process mouse events and update the cursor position
    //Using 200ms as pointer events buffer for show cursor trails

    final position = ref.read(audioProvider.notifier).positionInMs;

    if (position == _positionEvents.value) return;

    _positionEvents.value = position;

    final eventsInRange = List.of(
      _frames.where(
        (frame) => frame.time >= position - 200 && frame.time <= position,
      ),
    );

    final converted = eventsInRange
        .map((e) => ReplayFrameEvent(e.time, e.pos))
        .toList();

    if (converted.isEmpty) return;

    if (converted.last.position != _cursorEvents.value.lastOrNull?.position) {
      _cursorEvents.value = converted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final showTrail = ref.watch(
      storageProvider.select((it) => it.showCursorTrail),
    );

    return CustomPaint(
      painter: ReplayMousePainter(
        events: _cursorEvents,
        position: _positionEvents,
        showTrail: showTrail,
        cursorImage: _mouseImage,
      ),
    );
  }
}
