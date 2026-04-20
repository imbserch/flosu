import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

class TooltipService extends StateNotifier<({Widget? content, bool hidden})> {
  TooltipService() : super((content: null, hidden: true));

  Timer? _changeTimer;

  void showTooltip(Widget content) {
    _changeTimer?.cancel();
    state = (content: content, hidden: false);
  }

  void hideTooltip() {
    state = (content: state.content, hidden: true);
    _changeTimer?.cancel();
    _changeTimer = Timer(
      Durations.short2,
      () => state = (content: null, hidden: true),
    );
  }
}

final tooltipService = StateNotifierProvider((_) => TooltipService());
