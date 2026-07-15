part of "base.dart";

class NoScope extends ConfigurableMod {
  @override
  String get assetPath => AppMods.ns;

  @override
  Mod get mod => Mod.noScope;

  @override
  String get description => "Where's the cursor?";

  @override
  Color get color => AppColors.pink;

  @override
  bool get ranked => true;

  @override
  Set<ConfigurableMod> get incompatibleMods => {
    // Bloom(),
  };
}
