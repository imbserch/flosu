import 'package:flosu/models/mods/base.dart';
import 'package:flutter/material.dart';

class ModIcon extends StatelessWidget {
  const ModIcon({
    super.key,
    required this.mod,
    required this.selected,
    this.size = 20,
  }) : isDisplay = false;

  const ModIcon.display({super.key, required this.mod, this.size = 12})
    : selected = true,
      isDisplay = true;

  final ConfigurableMod mod;
  final bool selected;
  final double size;

  final bool isDisplay;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      child: Align(
        widthFactor: isDisplay ? .45 : 1,
        child: Transform.rotate(
          angle: 1 / 2,
          child: TweenAnimationBuilder(
            tween: Tween(end: selected ? 1.0 : 0.0),
            duration: Durations.short1,
            curve: Curves.easeIn,
            builder: (_, t, _) => Container(
              decoration: ShapeDecoration(
                color: Color.lerp(const Color(0xff455446), mod.color, t),
                shape: const StarBorder.polygon(pointRounding: .25, sides: 6),
              ),
              child: Transform.rotate(
                angle: -1 / 2,
                child: SizedBox.square(
                  dimension: size,
                  child: Image.asset(
                    mod.assetPath,
                    width: size,
                    height: size,
                    color: Color.lerp(Colors.white, Colors.black, t),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
