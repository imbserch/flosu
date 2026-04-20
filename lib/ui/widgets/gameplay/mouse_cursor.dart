import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide PointerEvent, Image;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' hide PointerEvent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flosu/core/extensions.dart';
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
  late Ticker _mouseTicker;
  //List<PointerEvent> _events = [];

  final ValueNotifier<List<PointerEvent>> _eventsNotifier = ValueNotifier([]);

  Image? _mouseImage;

  @override
  initState() {
    _instantiateCursorImage();
    _mouseTicker = Ticker(_updateEvents)..start();
    ref.read(inputProvider.notifier).addDelayedHandler(_getEvents);

    super.initState();
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

  void _getEvents(InputEvents events) {
    if (events.pointer.isEmpty) return;

    _eventsNotifier.value = [..._eventsNotifier.value, ...events.pointer];
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
  dispose() {
    _mouseTicker.stop();

    //Widget is unsafe, calling from root navigator
    globalRef.read(inputProvider.notifier).removeDelayedHandler(_getEvents);
    super.dispose();
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
/* 
class Mouse extends ConsumerStatefulWidget {
  const Mouse({super.key}) : color = null, events = null;

  const Mouse.fromEvents({
    super.key,
    required List<PointerEventWithTimestamp> all,
    this.color,
  }) : events = all;

  final List<PointerEventWithTimestamp>? events;
  final Color? color;

  @override
  ConsumerState<Mouse> createState() => _MouseState();
}

class _MouseState extends ConsumerState<Mouse> with InputHandler {
  late Ticker _mouseTicker;
  List<PointerEventWithTimestamp> _events = [];

  final Shader _gradientShader = const RadialGradient(
    colors: [Colors.white, Colors.transparent],
    stops: [0, 1],
    tileMode: .decal,
  ).createShader(Rect.fromCenter(center: .zero, width: 16, height: 16));

  late final _pointShader = LinearGradient(
    colors: [
      Color.lerp(widget.color ?? Colors.pink, Colors.white, .25)!,
      widget.color ?? Colors.pink,
    ],
    stops: [0, 1],
    begin: .topCenter,
    end: .bottomCenter,
  ).createShader(Rect.fromCenter(center: .zero, width: 27, height: 27));

  @override
  initState() {
    _mouseTicker = Ticker((_) => _updateEvents())..start();

    super.initState();
  }

  @override
  dispose() {
    _mouseTicker.stop();
    super.dispose();
  }

  void _updateEvents() {
    final now = DateTime.now().millisecondsSinceEpoch;

    if (widget.events != null) {
      final updatedElements = widget.events!
          .where((e) => (now - e.timestamp) < 200)
          .toList();

      if (updatedElements.isNotEmpty) {
        if (mounted) setState(() => _events = updatedElements);
      }
    } else {
      final updatedElements = _events
          .where((e) => (now - e.timestamp) < 200)
          .toList();

      if (updatedElements.isNotEmpty) {
        if (updatedElements.length != _events.length) {
          if (mounted) setState(() => _events = updatedElements);
        }
      }
    }
  }

  @override
  /* bool input(_, PointerEvent? ev, [_ = false]) {
    if (widget.events != null) return false;
    if (ev == null) return false;

    if (mounted) {
      setState(() => _events.add(PointerEventWithTimestamp(ev)));
    }
    return false;
  } */
  @override
  Widget build(BuildContext context) {
    final showTrail = ref.watch(
      storageNotifier.select((it) => it.showCursorTrail),
    );

    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          willChange: true,
          painter: MousePainter(
            List.of(_events),
            showTrail,
            _gradientShader,
            _pointShader,
            widget.color ?? Colors.pink,
          ),
        ),
      ),
    );
  }
}
 */