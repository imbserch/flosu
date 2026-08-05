import 'dart:ui' show Color;

import 'package:flosu/core/extensions/models.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/shared/domain/mod/mod.dart';
import 'package:flosu/shared/domain/replay/replay_frame.dart';
import 'package:flutter/material.dart' show Colors;

enum Rank {
  xh("SS", Colors.white),
  x("SS", AppColors.purple),
  sh("S", Colors.white),
  s("S", AppColors.lightBlue),
  a("A", AppColors.green),
  b("B", AppColors.yellow),
  c("C", Colors.orange),
  d("D", AppColors.red),
  f("F", Colors.red);

  final String name;
  final Color color;
  const Rank(this.name, this.color);
}

// Use non-final fields for building
class Replay {
  late final int version;
  late final String hash;

  String? filePath;

  String playerName = "osu!";

  int score = 0, maxCombo = 0;

  Statistics stats = Statistics();
  Statistics maxStats = Statistics();

  bool perfect = false;

  Set<Mod> mods = {};

  int timestamp = 0;

  List<ReplayFrame> frames = [];

  double get accuracy {
    if (stats.totalHits == 0) return 1;
    if (maxStats.totalHits == 0) return 1;

    final statsAcc =
        (stats.greats * 300) + (stats.oks * 100) + (stats.mehs * 50);
    final maxStatsAcc = maxStats.totalHits * 300;

    return statsAcc / maxStatsAcc;
  }

  Rank get rank {
    print(mods.map((m) => m.info.acronym));

    final hasHiddenMods =
        mods.containsMod(.hidden) || mods.containsMod(.flashlight);
    final hasNoMisses = stats.misses == 0;

    return switch (accuracy) {
      1 => hasHiddenMods ? .xh : .x,
      >= 0.95 => hasNoMisses ? (hasHiddenMods ? .sh : .s) : .a,
      >= 0.9 => .a,
      >= 0.8 => .b,
      >= 0.7 => .c,
      _ => .d,
      // TODO (imbserch): add support for fail rank
    };
  }
}

class Statistics {
  int greats = 0, oks = 0, mehs = 0, misses = 0;

  int get totalHits => greats + oks + mehs + misses;
}
