part of "base.dart";

class NoScope extends ConfigurableMod {
  @override
  String get acronym => "NS";

  @override
  String get assetPath => AppMods.ns;

  @override
  String get name => "No Scope";

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
