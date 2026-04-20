import 'dart:async';

import 'package:flosu/ui/widgets/navigation/notifications_drawer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' hide PointerEvent;
import 'package:flutter/material.dart' hide PointerEvent;
import 'package:flutter/services.dart' hide PointerEvent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flosu/core/extensions.dart';
import 'package:flosu/logic/providers/input.dart';
import 'package:flosu/logic/providers/storage.dart';
import 'package:flosu/models/inputs/inputs.dart';
import 'package:flosu/logic/providers/router.dart';
import 'package:flosu/ui/widgets/background/parallax_background.dart';
import 'package:flosu/ui/widgets/overlay/volume_bar.dart';
import 'package:flosu/ui/widgets/navigation/settings_drawer.dart';
import 'package:flosu/ui/widgets/navigation/top_bar.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({
    super.key,
    required this.child,
    required this.forceTopBarClosed,
  });
  final bool forceTopBarClosed;
  final Widget child;

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  final _scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: "Main scaffold");

  Timer? _scrollTimer;

  double _scroll = 0;
  int _accScroll = 1;

  bool _topBarOpen = true;

  Set<LogicalKeyboardKey> _lastKeys = {};

  ScaffoldState? get scaffold => _scaffoldKey.currentState;
  bool get isSettingsOpen => scaffold?.isDrawerOpen ?? false;
  bool get isNotificationsOpen => scaffold?.isEndDrawerOpen ?? false;

  @override
  initState() {
    ref.read(inputProvider.notifier).addInmediateHandler(_onInput);
    super.initState();
  }

  @override
  dispose() {
    //_lastKeys.clear();
    //Widget is unsafe, calling from root navigator
    globalRef.read(inputProvider.notifier).removeInmediateHandler(_onInput);

    _scrollTimer?.cancel();
    super.dispose();
  }

  void _onInput(Set<LogicalKeyboardKey> keys, PointerEvent? pointer) {
    if (setEquals(_lastKeys, keys)) return;

    //Only intercept if scrolled
    if (pointer != null && pointer.scroll.dx.sign != 0) {
      _updateVolume(keys.isAltPressed, pointer);
    }

    //If CTRL+T pressed and keys state changed, toggle top bar
    if (keys.isCtrlPressed && keys.changedAndPressed("T", _lastKeys)) {
      _toggleTopBar();
    }

    //If CTRL+O pressed and keys state changed, toggle drawer
    if (keys.isCtrlPressed && keys.changedAndPressed("O", _lastKeys)) {
      isSettingsOpen ? scaffold?.closeDrawer() : scaffold?.openDrawer();
    }

    //If CTRL+N pressed and keys state changed, toggle notifications drawer
    if (keys.isCtrlPressed && keys.changedAndPressed("N", _lastKeys)) {
      isNotificationsOpen
          ? scaffold?.closeEndDrawer()
          : scaffold?.openEndDrawer();
    }

    _lastKeys = keys.toSet();
  }

  void _updateVolume(bool altPressed, PointerEvent ev) {
    if (ev.scroll.dx.sign == 0) return;

    //Accumulate scroll delta
    if (ev is PointerScrollEvent) {
      if (_scroll.sign != (-ev.scroll.dy).sign) {
        _scroll = 0;
        _accScroll = 1;
      }
      _scroll -= ev.scroll.dy / 10000 * _accScroll;
      _accScroll++;

      _scrollTimer?.cancel();
      _scrollTimer = Timer(const Duration(milliseconds: 16), () => _scroll = 0);
    }

    //If ALT pressed and is scrolling, adjust volume using acceleration
    if (altPressed) {
      final volume = ref.read(storageProvider).globalVolume;

      if (_scroll != 0) {
        ref.read(storageProvider.notifier).setGlobalVolume(volume + _scroll);
      }
    }
  }

  void _toggleTopBar() {
    if (mounted) setState(() => _topBarOpen = !_topBarOpen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      onDrawerChanged: (_) {
        if (mounted) setState(() {});
      },
      onEndDrawerChanged: (_) {
        if (mounted) setState(() {});
      },
      drawer: SettingsDrawer(
        onClose: () => isSettingsOpen ? scaffold?.closeDrawer() : null,
      ),
      endDrawer: NotificationsDrawer(
        onClose: () => isNotificationsOpen ? scaffold?.closeEndDrawer() : null,
      ),
      body: Stack(
        fit: .expand,
        children: [
          const ParallaxBackground(),
          TweenAnimationBuilder(
            duration: Durations.medium1,
            curve: Curves.easeOut,
            tween: Tween(
              end: isSettingsOpen
                  ? 32.0
                  : isNotificationsOpen
                  ? -32.0
                  : 0.0,
            ),
            builder: (_, t, child) =>
                Transform.translate(offset: Offset(t, 0), child: child),
            child: Column(
              children: [
                RepaintBoundary(
                  child: TweenAnimationBuilder(
                    duration: Durations.medium1,
                    curve: Curves.easeOut,
                    tween: Tween(
                      end: _topBarOpen && !widget.forceTopBarClosed ? 0.0 : 1.0,
                    ),
                    builder: (_, t, child) => ClipRect(
                      child: Align(
                        alignment: .bottomCenter,
                        heightFactor: 1 - t,
                        child: child,
                      ),
                    ),
                    child: TopBar(
                      onSettingsTap: () => scaffold?.openDrawer(),
                      onNotificationsTap: () => scaffold?.openEndDrawer(),
                    ),
                  ),
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
          const VolumeBar(),
        ],
      ),
    );
  }
}
