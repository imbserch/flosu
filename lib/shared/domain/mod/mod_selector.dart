import 'package:flosu/core/extensions/models.dart';
import 'package:flosu/shared/domain/mod/mod.dart';
import 'package:flosu/shared/logging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ModSelector extends Notifier<Set<Mod>> with Logging {
  @override
  Set<Mod> build() {
    requestLogger();
    ref.onDispose(removeLogger);

    return const {};
  }

  Set<Mod> _lastModConfig = {};

  void setMods(Set<Mod> mods) {
    _setLastConfig();
    state = mods;
  }

  void toggleMod(Mod mod) {
    _setLastConfig();
    if (state.containsMod(mod.info)) {
      // Remove
      state = {
        for (final m in state)
          if (m.info != mod.info) m,
      };
      return;
    }

    // Add
    state = {
      for (final m in state)
        if (!mod.incompatibleMods.contains(m.info)) m,
      mod,
    };
  }

  void clearMods() {
    log("Clearing mod configuration");
    _setLastConfig();
    state = {};
  }

  void _setLastConfig() => _lastModConfig = Set.of(state);

  void revert() {
    log('Reverting mod configuration');
    state = _lastModConfig;
    _lastModConfig = {};
  }
}

final modSelector = NotifierProvider(() => ModSelector());
