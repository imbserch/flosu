import 'dart:async';

import 'package:flosu/core/assets.dart';
import 'package:flosu/core/mixins.dart';
import 'package:flosu/logic/providers/main_layout.dart';
import 'package:flosu/logic/services/sample.dart';
import 'package:flosu/models/inputs/inputs.dart';
import 'package:flosu/ui/widgets/navigation/notifications_drawer.dart';
import 'package:flutter/material.dart' hide PointerEvent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flosu/logic/providers/settings.dart';
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

class _MainLayoutState extends ConsumerState<MainLayout>
    with KeyboardEventHandler {
  final _scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: "Main scaffold");

  Timer? _scrollTimer;

  ScaffoldState? get scaffold => _scaffoldKey.currentState;
  bool get isSettingsOpen => scaffold?.isDrawerOpen ?? false;
  bool get isNotificationsOpen => scaffold?.isEndDrawerOpen ?? false;

  @override
  void initState() {
    super.initState();

    ref.listenManual(
      mainLayoutProvider,
      _handleLayoutChange,
      fireImmediately: true,
    );
  }

  void _handleLayoutChange(_, MainLayoutState state) {
    if (state.isDrawersLocked) {
      scaffold?.closeDrawer();
      scaffold?.closeEndDrawer();
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    super.dispose();
  }

  @override
  Map<KeysState, VoidCallback> get keyHandlers => {
    //If CTRL+T pressed, toggle top bar
    KeysState({.keyT}, control: true): _toggleTopBar,
    //If CTRL+O pressed, toggle drawer
    KeysState({.keyO}, control: true): _toggleSettings,
    //If CTRL+F11 pressed, toggle fps monitor
    KeysState({.f11}, control: true): _toggleFpsMonitor,
    //If CTRL+F9 pressed, toggle logs
    KeysState({.f9}, control: true): _toggleLogs,
    //If CTRL+N pressed, toggle notifications drawer
    KeysState({.keyN}, control: true): _toggleNotifications,
    //If CTRL+ALT+F4 pressed, force game reload
    KeysState({.f4}, control: true, alt: true): _forceReload,
  };

  void _toggleTopBar() {
    ref.read(mainLayoutProvider.notifier).toggleTopBar();
  }

  void _toggleSettings() {
    isSettingsOpen ? scaffold?.closeDrawer() : scaffold?.openDrawer();
  }

  void _toggleFpsMonitor() {
    ref
        .read(settingsProvider.notifier)
        .setShowFpsMonitor(!ref.read(settingsProvider).fpsMonitorEnabled);
  }

  void _toggleLogs() {
    ref
        .read(settingsProvider.notifier)
        .setShowLogs(!ref.read(settingsProvider).logsEnabled);
  }

  void _toggleNotifications() {
    isNotificationsOpen
        ? scaffold?.closeEndDrawer()
        : scaffold?.openEndDrawer();
  }

  void _forceReload() {
    scaffold?.closeEndDrawer();
    context.go("/splash");
  }

  /* 
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
        final volume = ref.read(settingsProvider).globalVolume;
        final clampedVol = (volume + _scroll).clamp(0.0, 1.0);

        ref.read(settingsProvider.notifier).setGlobalVolume(clampedVol);
        ref.read(sampleService).play(AppSamples.uiCursorTap);
      }
    }
  }
 */
  void _handleDrawerChange(bool isOpen) {
    ref
        .read(sampleService)
        .play(isOpen ? AppSamples.uiSettingsPopIn : AppSamples.uiMenuClose);

    if (mounted) setState(() {});
  }

  int get translateSign {
    final state = ref.read(mainLayoutProvider);

    if (state.isDrawersLocked) return 0;

    if (isSettingsOpen) return 1;
    if (isNotificationsOpen) return -1;

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mainLayoutProvider);

    return Scaffold(
      key: _scaffoldKey,
      onDrawerChanged: _handleDrawerChange,
      onEndDrawerChanged: _handleDrawerChange,
      drawer: state.isDrawersLocked
          ? null
          : SettingsDrawer(
              onClose: () => isSettingsOpen ? scaffold?.closeDrawer() : null,
            ),
      endDrawer: state.isDrawersLocked
          ? null
          : NotificationsDrawer(
              onClose: () =>
                  isNotificationsOpen ? scaffold?.closeEndDrawer() : null,
            ),
      body: SafeArea(
        left: false,
        right: false,
        bottom: false,
        top: false,
        child: Stack(
          fit: .expand,
          children: [
            const ParallaxBackground(),
            TweenAnimationBuilder(
              duration: Durations.medium1,
              curve: Curves.easeOut,
              tween: Tween(end: 32.0 * translateSign),
              builder: (_, t, child) =>
                  Transform.translate(offset: Offset(t, 0), child: child),
              child: Column(
                children: [
                  RepaintBoundary(
                    child: TweenAnimationBuilder(
                      duration: Durations.medium1,
                      curve: Curves.easeOut,
                      tween: Tween(
                        end: state.isTopBarLocked || !state.isTopBarOpen
                            ? 1.0
                            : 0.0,
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
      ),
    );
  }
}
