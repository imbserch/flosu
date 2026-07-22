import 'dart:ui';

import 'package:flosu/core/assets.dart';
import 'package:flosu/core/engine/game_loop.dart';
import 'package:flosu/shared/input.dart';
import 'package:flosu/shared/logging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide PointerEvent, Image;
import 'package:flutter/services.dart' hide PointerEvent;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flosu/features/settings/domain/settings.dart';
import 'package:flosu/features/gameplay/presentation/painters/gameplay.dart';

class CursorFrame {
  CursorFrame(this.timestamp, this.offset);

  final int timestamp;
  final Offset offset;
}

class CursorFramesNotifier extends ChangeNotifier
    implements ValueListenable<List<CursorFrame>> {
  final List<CursorFrame> _events = [];

  @override
  List<CursorFrame> get value => _events;

  void add(CursorFrame frame) {
    _events.add(frame);
    notifyListeners();
  }

  void updateEvents(int maxAge) {
    if (_events.isEmpty) return;

    final now = GameLoop.time;

    final threshold = now - maxAge;
    int removeCount = 0;

    // Keep at least the last event so the list is never empty
    final limit = _events.length - 1;
    while (removeCount < limit && _events[removeCount].timestamp < threshold) {
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

class _MouseCursorState extends ConsumerState<MouseCursor>
    with MouseHandler, Logging, GameLoopListener {
  final CursorFramesNotifier _cursorFramesNotifier = CursorFramesNotifier();

  late int _lastTick = time;

  Image? _mouseImage;

  @override
  initState() {
    requestLogger();
    _instantiateCursorImage();
    super.initState();
  }

  @override
  bool input() {
    if (mouse.scrolling) return false;

    final now = time;

    // Skip if less than 2ms has passed since last input tick.
    // Some mice send multiple events in a single tick.
    //
    // That means: The maximum polling rate allowed here is 500hz
    if (now < _lastTick + 2) return false;

    final frame = CursorFrame(now, mouse.position);
    _cursorFramesNotifier.add(frame);
    _lastTick = now;

    return false;
  }

  @override
  void process(double delta) {
    _cursorFramesNotifier.updateEvents(200);
  }

  @override
  dispose() {
    removeLogger();
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
      log("Error loading mouse as a ui.Image: $err", level: .error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cursorTrailEnabled = ref.watch(
      settingsProvider.select((it) => it.cursorTrailEnabled),
    );

    return IgnorePointer(
      child: CustomPaint(
        painter: MousePainter(
          events: _cursorFramesNotifier,
          showTrail: cursorTrailEnabled,
          cursorImage: _mouseImage,
        ),
      ),
    );
  }
}
