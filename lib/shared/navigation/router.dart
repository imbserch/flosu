import 'package:flosu/ui/pages/gameplay/pause.dart';
import 'package:flosu/ui/pages/song_select/replay_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flosu/ui/pages/gameplay/gameplay.dart';
import 'package:flosu/ui/pages/gameplay/loader.dart';
import 'package:flosu/shared/layout/main_layout.dart';
import 'package:flosu/ui/pages/main_menu/select.dart';
import 'package:flosu/ui/pages/results/results.dart';
import 'package:flosu/ui/pages/song_select/select.dart';
import 'package:flosu/ui/pages/splash/splash.dart';
import 'package:flosu/ui/pages/song_select/mods.dart';

// The router is used to navigate between different pages in the app.
// It's a pretty complex router, but it's also very flexible.
//
// The router tree is:
// /splash                  (Loader of all required resources. It will always be the first page)
// /main                    (Main menu)
//    /songs                (Song select)
//       /mods              (Mods selection)
//       /pick-replay       (Replay picker)
//    /load                 (Loader of a single beatmap)
// /gameplay                (Gameplay)
//    /pause                (Pause)
// /scoring                 (Results)
//
// The routes will contain both StatefulWidget and AnimatablePage widgets
// AnimatablePage is a custom StatefulWidget that is used to animate between pages
// And it exposes a function to build the page.
//
// buildPage() is a helper function that is used to build the page
// It is used to build the page and it's used by AnimatablePages to animate between pages.

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
          forceTopBarClosed: state.uri.pathSegments.any(
            (pathSegment) => ["splash", "gameplay"].contains(pathSegment),
          ),
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
              // New route, we will use it in the next feature
              // it will remove the FilePicker package
              GoRoute(
                path: '/pick-replay',
                pageBuilder: (_, s) => buildPage(
                  s,
                  ReplayPickerPage(key: ValueKey(s.name), uri: s.uri),
                ),
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
            routes: [
              GoRoute(
                path: '/pause',
                pageBuilder: (_, s) =>
                    buildPage(s, PausePage(key: ValueKey(s.name), uri: s.uri)),
              ),
            ],
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

ProviderContainer get globalRef =>
    ProviderScope.containerOf(rootNavigatorKey.currentContext!);
