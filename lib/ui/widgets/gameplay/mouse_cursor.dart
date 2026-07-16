import 'dart:ui';

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
import 'package:flosu/logic/providers/settings.dart';
import 'package:flosu/models/inputs/inputs.dart';
import 'package:flosu/logic/providers/router.dart';
import 'package:flosu/ui/painters/gameplay.dart';

class EventListNotifier extends ChangeNotifier
    implements ValueListenable<List<PointerEvent>> {
  final List<PointerEvent> _events = [];

  @override
  List<PointerEvent> get value => _events;

  void addAll(Iterable<PointerEvent> newEvents) {
    _events.addAll(newEvents);
    notifyListeners();
  }

  void updateEvents(DateTime now, Duration maxAge) {
    if (_events.isEmpty) return;

    final threshold = now.subtract(maxAge);
    int removeCount = 0;

    // Keep at least the last event so the list is never empty
    final limit = _events.length - 1;
    while (removeCount < limit &&
        _events[removeCount].timestamp.isBefore(threshold)) {
      removeCount++;
    }

    if (removeCount > 0) {
      _events.removeRange(0, removeCount);
      notifyListeners();
    }
  }
}

class MouseCursor extends ConsumerStatefulWidget {
  const MouseCursor({super.key});

  @override
  ConsumerState<MouseCursor> createState() => _MouseCursorState();
}

class _MouseCursorState extends ConsumerState<MouseCursor> {
  final ScopedLogger _logger = Logger.requestLogger("MouseCursor");
  final EventListNotifier _eventsNotifier = EventListNotifier();

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

    _eventsNotifier.addAll(events.pointer);

    // Look for press events and fire click sample if necessary
    for (final event in events.pointer) {
      if (event.pressed != _pressed) {
        _pressed = event.pressed;

        if (event.pressed && _pressed) {
          // Play Tap Sound
          ref.read(sampleService).play(AppSamples.uiCursorTap);
          break;
        }
      }
    }
  }

  void _updateEvents(_) {
    _eventsNotifier.updateEvents(DateTime.now(), Durations.short4);
  }

  @override
  Widget build(BuildContext context) {
    final cursorTrailEnabled = ref.watch(
      settingsProvider.select((it) => it.cursorTrailEnabled),
    );

    return IgnorePointer(
      child: CustomPaint(
        painter: MousePainter(
          events: _eventsNotifier,
          showTrail: cursorTrailEnabled,
          cursorImage: _mouseImage,
        ),
      ),
    );
  }
}
