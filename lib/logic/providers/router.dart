import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flosu/ui/pages/gameplay/gameplay.dart';
import 'package:flosu/ui/pages/gameplay/loader.dart';
import 'package:flosu/layout/main_layout.dart';
import 'package:flosu/ui/pages/main_menu/select.dart';
import 'package:flosu/ui/pages/results/results.dart';
import 'package:flosu/ui/pages/song_select/select.dart';
import 'package:flosu/ui/pages/splash/splash.dart';
import 'package:flosu/ui/pages/song_select/mods.dart';
import 'package:flosu/ui/widgets/common/skewed_box.dart';

ProviderContainer get globalRef =>
    ProviderScope.containerOf(rootNavigatorKey.currentContext!);

/// Represents an action button configured for a custom dialog box.
///
/// Contains the display [label] widget, the color layout [color] of the button,
/// and the callback [onTap] executed when clicked.
class DialogAction {
  DialogAction({
    required this.label,
    required this.onTap,
    this.color = Colors.black,
  });

  final Widget label;
  final VoidCallback onTap;
  final Color color;
}

Future<T?> openDialog<T extends Object>({
  required Widget title,
  required Widget content,
  required Widget icon,
  required List<DialogAction> Function(BuildContext context) actionsBuilder,
}) async {
  return await showDialog<T?>(
    context: rootNavigatorKey.currentContext!,
    animationStyle: const AnimationStyle(
      curve: Curves.elasticOut,
      duration: Durations.medium1,
      reverseCurve: Curves.easeIn,
      reverseDuration: Durations.medium1,
    ),
    builder: (context) => TweenAnimationBuilder(
      tween: Tween(begin: .75, end: 1.0),
      curve: Curves.elasticOut,
      duration: Durations.extralong4,
      builder: (_, t, child) => Opacity(
        opacity: min((t - .75) * 4, 1.0),
        child: Transform.scale(filterQuality: .none, scale: t, child: child),
      ),
      child: Dialog(
        insetAnimationDuration: Durations.medium1,
        insetAnimationCurve: Curves.easeOut,
        insetPadding: .zero,
        shape: RoundedRectangleBorder(borderRadius: .circular(12)),
        backgroundColor: const Color(0xff241b23),
        clipBehavior: .antiAliasWithSaveLayer,
        child: Container(
          padding: const .fromLTRB(0, 24, 0, 36),
          width: 310,
          child: Column(
            crossAxisAlignment: .stretch,
            mainAxisSize: .min,
            children: [
              IconTheme(
                data: const IconThemeData(size: 48, color: Colors.white),
                child: icon,
              ),
              const SizedBox(height: 20),
              DefaultTextStyle.merge(
                textAlign: .center,
                style: const TextStyle(fontSize: 12, height: 1),
                child: title,
              ),
              const SizedBox(height: 12),
              DefaultTextStyle.merge(
                textAlign: .center,
                style: const TextStyle(fontSize: 10, height: 1),
                child: content,
              ),
              const SizedBox(height: 26),
              Container(
                padding: const .symmetric(horizontal: 24),
                color: const Color(0xff150e14),
                child: Column(
                  crossAxisAlignment: .stretch,
                  children: actionsBuilder(context)
                      .map(
                        (a) => SkewedBox(
                          onTap: a.onTap,
                          padding: const .all(8),
                          decoration: BoxDecoration(
                            color: a.color,
                            borderRadius: .zero,
                          ),
                          child: DefaultTextStyle.merge(
                            textAlign: .center,
                            style: const TextStyle(
                              fontSize: 10,
                              height: 1,
                              fontWeight: .w700,
                            ),
                            child: a.label,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Page buildPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    opaque: state.uri.pathSegments.length < 2,
    transitionDuration: Durations.short4,
    reverseTransitionDuration: Durations.short4,
    child: child,
    transitionsBuilder: (context, anim, revAnim, childWidget) {
      return childWidget;
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: "/splash",
    onException: (_, _, router) => router.go("/main"),
    routes: [
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (_, state, child) => MainLayout(
          forceTopBarClosed: [
            "splash",
            "gameplay",
          ].contains(state.uri.pathSegments.last),
          child: child,
        ),
        routes: [
          // Splash (Loading initial resources like beatmaps)
          GoRoute(
            path: '/splash',
            pageBuilder: (_, s) => buildPage(s, const SplashPage()),
          ),

          // All routes (All resources loaded)
          GoRoute(
            path: '/main',
            pageBuilder: (_, s) =>
                buildPage(s, MainSelectPage(key: ValueKey(s.name), uri: s.uri)),
          ),
          GoRoute(
            path: '/songs',
            pageBuilder: (_, s) =>
                buildPage(s, SongSelectPage(key: ValueKey(s.name), uri: s.uri)),
            routes: [
              GoRoute(
                path: '/mods',
                pageBuilder: (_, s) =>
                    buildPage(s, ModsPage(key: ValueKey(s.name), uri: s.uri)),
              ),
            ],
          ),

          //Gameplay and loader
          GoRoute(
            path: '/load',
            pageBuilder: (_, s) => buildPage(s, const GameplayLoaderPage()),
          ),
          GoRoute(
            path: '/gameplay',
            pageBuilder: (_, s) =>
                buildPage(s, GameplayPage(key: ValueKey(s.name), uri: s.uri)),
          ),

          //Score results
          GoRoute(
            path: '/scoring',
            pageBuilder: (_, s) =>
                buildPage(s, ResultsPage(key: ValueKey(s.name), uri: s.uri)),
          ),
        ],
      ),
    ],
  );
});

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');
