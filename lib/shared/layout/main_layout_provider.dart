import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainLayoutState {
  MainLayoutState({
    this.isTopBarOpen = false,
    this.isTopBarLocked = true,
    this.isDrawersLocked = false,
  });

  final bool isTopBarOpen;
  final bool isTopBarLocked;
  final bool isDrawersLocked;

  MainLayoutState copyWith({
    bool? isTopBarOpen,
    bool? isTopBarLocked,
    bool? isDrawersLocked,
  }) => MainLayoutState(
    isTopBarOpen: isTopBarOpen ?? this.isTopBarOpen,
    isTopBarLocked: isTopBarLocked ?? this.isTopBarLocked,
    isDrawersLocked: isDrawersLocked ?? this.isDrawersLocked,
  );
}

class MainLayoutNotifier extends Notifier<MainLayoutState> {
  @override
  MainLayoutState build() => MainLayoutState();

  void toggleTopBar() {
    state = state.copyWith(isTopBarOpen: !state.isTopBarOpen);
  }

  void setTopBarLocked(bool isLocked) {
    state = state.copyWith(isTopBarLocked: isLocked);
  }

  void setDrawersLocked(bool isLocked) {
    state = state.copyWith(isDrawersLocked: isLocked);
  }
}

final mainLayoutProvider = NotifierProvider(() => MainLayoutNotifier());
