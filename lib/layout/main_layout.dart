import 'dart:async';

import 'package:flosu/core/assets.dart';
import 'package:flosu/logic/providers/input.dart';
import 'package:flosu/logic/providers/router.dart';
import 'package:flosu/logic/services/sample.dart';
import 'package:flosu/ui/widgets/navigation/notifications_drawer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide PointerEvent;
import 'package:flutter/services.dart' hide PointerEvent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flosu/core/extensions/models.dart';
import 'package:flosu/logic/providers/storage.dart';
import 'package:flosu/models/inputs/inputs.dart';
import 'package:flosu/ui/widgets/background/parallax_background.dart';
import 'package:flosu/ui/widgets/overlay/volume_bar.dart';
import 'package:flosu/ui/widgets/navigation/settings_drawer.dart';
import 'package:flosu/ui/widgets/navigation/top_bar.dart';
import 'package:go_router/go_router.dart';

/// The shell layout widget that envelopes the application pages.
///
/// Manages global overlays such as the volume slider, side navigation/settings drawers,
/// parallax background, and the standard top bar layout.
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
  void initState() {
    super.initState();
    ref.read(inputProvider.notifier).addInmediateHandler(_onInput);
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    globalRef.read(inputProvider.notifier).removeInmediateHandler(_onInput);
    super.dispose();
  }

  bool _onInput(Set<LogicalKeyboardKey> keys, PointerEvent? pointer) {
    //Mouse events are only intercept if scrolled
    if (pointer != null) {
      _updateVolume(keys.isAltPressed, pointer);
    }

    if (setEquals(_lastKeys, keys)) return false;

    bool handled = false;

    if (keys.isCtrlPressed) {
      //If CTRL+T pressed and keys state changed, toggle top bar
      if (keys.changedAndPressed(LogicalKeyboardKey.keyT, _lastKeys)) {
        _toggleTopBar();
        handled = true;
      }

      //If CTRL+O pressed and keys state changed, toggle drawer
      if (keys.changedAndPressed(LogicalKeyboardKey.keyO, _lastKeys)) {
        isSettingsOpen ? scaffold?.closeDrawer() : scaffold?.openDrawer();
        handled = true;
      }

      //If CTRL+F11 pressed and keys state changed, toggle fps monitor
      if (keys.changedAndPressed(LogicalKeyboardKey.f11, _lastKeys)) {
        final showFpsMonitor = ref.read(storageProvider).showFpsMonitor;
        ref.read(storageProvider.notifier).setShowFpsMonitor(!showFpsMonitor);
        handled = true;
      }

      //If CTRL+F9 pressed and keys state changed, toggle logs
      if (keys.changedAndPressed(LogicalKeyboardKey.f9, _lastKeys)) {
        final showLogs = ref.read(storageProvider).showLogs;
        ref.read(storageProvider.notifier).setShowLogs(!showLogs);
        handled = true;
      }

      //If CTRL+N pressed and keys state changed, toggle notifications drawer
      if (keys.changedAndPressed(LogicalKeyboardKey.keyN, _lastKeys)) {
        isNotificationsOpen
            ? scaffold?.closeEndDrawer()
            : scaffold?.openEndDrawer();
        handled = true;
      }

      //If CTRL+ALT+F4 pressed and keys state changed
      //Force game reload
      if (keys.isAltPressed) {
        if (keys.changedAndPressed(LogicalKeyboardKey.f4, _lastKeys)) {
          scaffold?.closeEndDrawer();
          context.go("/splash");
          handled = true;
        }
      }
    }

    _lastKeys = keys.toSet();
    return handled;
  }

  void _updateVolume(bool altPressed, PointerEvent ev) {
    //Accumulate scroll delta
    if (ev.scroll.dy.sign != 0) {
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
      if (_scroll != 0) {
        final volume = ref.read(storageProvider).globalVolume;
        final clampedVol = (volume + _scroll).clamp(0.0, 1.0);

        ref.read(storageProvider.notifier).setGlobalVolume(clampedVol);
        ref.read(sampleService).play(AppSamples.uiCursorTap);
      }
    }
  }

  void _toggleTopBar() {
    if (mounted) setState(() => _topBarOpen = !_topBarOpen);
  }

  void _handleDrawerChange(bool isOpen) {
    ref
        .read(sampleService)
        .play(isOpen ? AppSamples.uiSettingsPopIn : AppSamples.uiMenuClose);

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      onDrawerChanged: _handleDrawerChange,
      onEndDrawerChanged: _handleDrawerChange,
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
