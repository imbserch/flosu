import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flosu/core/assets.dart';
import 'package:flosu/core/enums.dart';
import 'package:flosu/logic/services/game_loop.dart';
import 'package:flosu/logic/services/logger.dart';
import 'package:flosu/logic/services/sample.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide PointerEvent, Image;
import 'package:flutter/services.dart' hide PointerEvent;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flosu/logic/providers/input.dart';
import 'package:flosu/logic/providers/storage.dart';
import 'package:flosu/models/inputs/inputs.dart';
import 'package:flosu/logic/providers/router.dart';
import 'package:flosu/ui/painters/gameplay.dart';

class MouseCursor extends ConsumerStatefulWidget {
  const MouseCursor({super.key});

  @override
  ConsumerState<MouseCursor> createState() => _MouseCursorState();
}

class _MouseCursorState extends ConsumerState<MouseCursor> {
  final ScopedLogger _logger = Logger.requestLogger("MouseCursor");
  final ValueNotifier<List<PointerEvent>> _eventsNotifier = ValueNotifier([]);

  Image? _mouseImage;
  bool _pressed = false;

  @override
  initState() {
    _instantiateCursorImage();

    ref.read(gameLoopService).subscribe(TickerPhase.visual, _updateEvents);
    ref.read(inputProvider.notifier).addDelayedHandler(_getEvents);

    super.initState();
  }

  @override
  dispose() {
    //Widget is unsafe, calling from root navigator
    globalRef
        .read(gameLoopService)
        .unsubscribe(TickerPhase.visual, _updateEvents);

    globalRef.read(inputProvider.notifier).removeDelayedHandler(_getEvents);
    _logger.dispose();
    super.dispose();
  }

  void _instantiateCursorImage() async {
    try {
      final data = await rootBundle.load(AppImages.cursor);
      final view = Uint8List.view(data.buffer);
      final codec = await instantiateImageCodec(view);
      final frame = await codec.getNextFrame();

      _mouseImage = frame.image;
      if (mounted) setState(() {});
    } catch (err) {
      _logger.error("Error loading mouse as a ui.Image: $err");
    }
  }

  void _getEvents(InputEvents events) {
    if (events.pointer.isEmpty) return;

    // Call this first to ensure that the list has the most recent events
    _eventsNotifier.value = [..._eventsNotifier.value, ...events.pointer];

    // Look for press events and fire click sample if necessary
    for (final event in events.pointer) {
      if (event.pressed != _pressed) {
        _pressed = event.pressed;

        if (event.pressed && _pressed) {
          // Play Tap Sound
          ref.read(sampleService).play(AppSamples.uiCursorTap);
        }
      }
    }
  }

  void _updateEvents(_) {
    //Don't try to remove the last event
    if (_eventsNotifier.value.length == 1) return;

    final onlyInRange = _eventsNotifier.value.where(
      (e) => DateTime.now().difference(e.timestamp) <= Durations.short4,
    );

    List<PointerEvent> oldEvents = [
      ...onlyInRange,
      if (onlyInRange.isEmpty) ?_eventsNotifier.value.lastOrNull,
    ];

    if (!listEquals(_eventsNotifier.value, oldEvents)) {
      _eventsNotifier.value = oldEvents;
    }
  }

  @override
  Widget build(BuildContext context) {
    final showTrail = ref.watch(storageProvider).showCursorTrail;
    return IgnorePointer(
      child: CustomPaint(
        painter: MousePainter(
          events: _eventsNotifier,
          showTrail: showTrail,
          cursorImage: _mouseImage,
        ),
      ),
    );
  }
}
