part of 'base.dart';

/// Renders a [Spinner] onto the playfield canvas.
///
/// > ⚠️ **Not yet implemented.** This painter is a stub. Spinner rendering and
/// > hit detection are planned for a future iteration.
class SpinnerPainter extends HitObjectPainter {
  SpinnerPainter(this.object, super.position, super.difficulty, super.mods);

  /// The spinner hit object to render.
  final Spinner object;

  @override
  void paint(Canvas canvas, Size s) {
    // TODO: Implement spinner rendering.
  }
}
