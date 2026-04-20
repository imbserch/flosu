import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TooltipProvider extends Notifier<({Widget? content, bool hidden})> {
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

  @override
  ({Widget? content, bool hidden}) build() => (content: null, hidden: true);
}

final tooltipProvider = NotifierProvider(() => TooltipProvider());
