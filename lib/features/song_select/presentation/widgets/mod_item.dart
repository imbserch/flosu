import 'package:flosu/shared/domain/mod/mod.dart';
import 'package:flosu/shared/widgets/skewed_box.dart';
import 'package:flosu/features/song_select/presentation/widgets/mod_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ModItem extends ConsumerWidget {
  const ModItem({
    super.key,
    required this.mod,
    required this.selected,
    required this.onTap,
  });

  final Mod mod;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TweenAnimationBuilder(
      tween: Tween(end: selected ? 1.0 : 0.0),
      duration: Durations.short1,
      curve: Curves.easeIn,
      builder: (_, t, _) => SkewedBox.ignoreParentSkew(
        onTap: onTap,
        useGradientBorder: true,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Color.lerp(const Color(0xff39463a), mod.color, t / 3),
        ),
        child: Row(
          children: [
            SkewedBox(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              child: ModIcon(mod: mod, selected: selected),
            ),
            Expanded(
              child: SkewedBox(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Color.lerp(const Color(0xff455446), mod.color, t),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      mod.info.name,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: Color.lerp(Colors.white, Colors.black, t),
                      ),
                    ),
                    Text(
                      mod.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 6,
                        color: Color.lerp(Colors.white, Colors.black, t),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
