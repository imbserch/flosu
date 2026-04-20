import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_fade/image_fade.dart' show ImageFade;
import 'package:flosu/core/extensions.dart';
import 'package:flosu/logic/providers/audio.dart';
import 'package:flosu/logic/providers/input.dart';
import 'package:flosu/logic/providers/storage.dart';
import 'package:flosu/models/inputs/inputs.dart';

class ParallaxBackground extends ConsumerStatefulWidget {
  const ParallaxBackground({super.key});

  @override
  ConsumerState<ParallaxBackground> createState() => _ParallaxBackgroundState();
}

class _ParallaxBackgroundState extends ConsumerState<ParallaxBackground> {
  Offset _offset = .zero;

  @override
  initState() {
    ref.read(inputProvider.notifier).addDelayedHandler(_onInput);
    super.initState();
  }

  @override
  dispose() {
    ref.read(inputProvider.notifier).removeDelayedHandler(_onInput);
    super.dispose();
  }

  void _onInput(InputEvents event) {
    final parallax = ref.read(storageProvider).parallax;

    if (event.pointer.isEmpty || !parallax) return;

    final currentPos = event.pointer.last.position;

    if (currentPos != _offset) {
      _offset = Offset(
        ((-currentPos.dx / context.screenScaled.width) / 10) + .05,
        ((-currentPos.dy / context.screenScaled.height) / 10) + .05,
      );

      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final blur = ref.watch(storageProvider.select((it) => it.backgroundBlur));
    final dim = ref.watch(storageProvider.select((it) => it.backgroundDim));
    final parallax = ref.watch(storageProvider.select((it) => it.parallax));

    final imageFile = ref.watch(
      audioProvider.select((it) => it?.background?.file),
    );

    final scale = parallax ? 1.0 : 0.0;

    final traslatedOffset = parallax
        ? _offset - const Offset(.5, .5)
        : Offset.zero;

    if (dim == 1) return const SizedBox();

    Widget image = ImageFade(
      key: const Key("Parallax image"),
      image: imageFile != null && dim != 1 ? FileImage(imageFile) : null,
      duration: Durations.long2,
      syncDuration: Durations.medium1,
      curve: Curves.fastOutSlowIn,
      fit: BoxFit.cover,
      loadingBuilder: (_, _, _) => const Center(),
      errorBuilder: (_, _) => const Center(),
    );

    if (blur > 0) {
      image = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blur * 8, sigmaY: blur * 8),
        child: image,
      );
    }

    if (dim > 0) {
      image = Opacity(opacity: 1 - dim, child: image);
    }

    return Transform(
      key: ValueKey(parallax),
      transform: .identity()
        ..translateByDouble(
          traslatedOffset.dx * 96,
          traslatedOffset.dy * 96,
          1,
          1,
        )
        ..scaleByDouble(1 + (.15 * scale), 1 + (.15 * scale), 1, 1),
      filterQuality: .low,
      child: image,
    );
  }
}
