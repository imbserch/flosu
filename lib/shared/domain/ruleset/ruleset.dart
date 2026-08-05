enum RulesetType { osu, taiko, catchTheBeat, mania }

/// Actually this class is unused.
sealed class Ruleset {
  factory Ruleset.osu() => Osu();
  factory Ruleset.taiko() => Taiko();
  factory Ruleset.catchTheBeat() => Catch();
  factory Ruleset.mania() => Mania();

  Ruleset(this.type);

  final RulesetType type;
}

class Osu extends Ruleset {
  Osu() : super(RulesetType.osu);
}

class Taiko extends Ruleset {
  Taiko() : super(RulesetType.taiko);
}

class Catch extends Ruleset {
  Catch() : super(RulesetType.catchTheBeat);
}

class Mania extends Ruleset {
  Mania() : super(RulesetType.mania);
}
