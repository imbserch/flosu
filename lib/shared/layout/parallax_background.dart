import 'dart:io';
import 'dart:ui';
import 'package:flosu/core/engine/game_loop.dart';
import 'package:flosu/shared/domain/beatmap/beatmap_selector.dart';
import 'package:flosu/shared/input/input_mixins.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_fade/image_fade.dart' show ImageFade;
import 'package:flosu/core/extensions/ui.dart';
import 'package:flosu/features/settings/domain/settings_provider.dart';

class ParallaxBackground extends ConsumerStatefulWidget {
  const ParallaxBackground({super.key});

  @override
  ConsumerState<ParallaxBackground> createState() => _ParallaxBackgroundState();
}

class _ParallaxBackgroundState extends ConsumerState<ParallaxBackground>
    with MouseHandler, GameLoopListener {
  final GlobalKey _imageKey = GlobalKey();
  Offset _offset = Offset.zero;

  @override
  bool input() => false;

  @override
  void process(_) {
    final parallaxEnabled = ref.read(settingsProvider).parallaxEnabled;

    if (!parallaxEnabled) return;

    final currentPos = mouse.position;

    final targetOffset =
        const Offset(-0.025, -0.025) +
        Offset(
          (currentPos.dx / context.screenScaled.width) / 20,
          (currentPos.dy / context.screenScaled.height) / 20,
        );

    if (targetOffset != _offset) {
      if (mounted) setState(() => _offset = targetOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final blur = ref.watch(settingsProvider.select((it) => it.backgroundBlur));
    final dim = ref.watch(settingsProvider.select((it) => it.backgroundDim));
    final parallaxEnabled = ref.watch(
      settingsProvider.select((it) => it.parallaxEnabled),
    );

    if (dim == 1) return const SizedBox();

    final imageFile = ref.watch(
      beatmapSelector.select((it) => it?.backgroundPath),
    );

    final width = context.screenScaled.width;

    ImageProvider? getProvider() {
      if (imageFile == null || dim == 1) return null;

      final baseProvider = FileImage(File(imageFile));

      if (blur > 0) {
        final double steppedBlur = ((blur * 4) / 4).clamp(0.25, 1.0);

        final int targetWidth = switch (steppedBlur) {
          <= 0.25 => 768,
          <= 0.50 => 512,
          <= 0.75 => 384,
          _ => 256,
        };

        return ResizeImage(baseProvider, width: targetWidth);
      }

      final targetWidth = ((width / 256).ceil() * 256).toInt().clamp(512, 1920);

      return ResizeImage(baseProvider, width: targetWidth);
    }

    Widget image = ImageFade(
      key: _imageKey,
      image: getProvider(),
      duration: Durations.long2,
      syncDuration: Durations.long2,
      curve: Curves.fastOutSlowIn,
      fit: BoxFit.cover,
      loadingBuilder: (_, _, _) => const Center(),
      errorBuilder: (_, _) => const Center(),
    );

    return Opacity(
      opacity: 1 - dim,
      child: AnimatedSlide(
        offset: parallaxEnabled && dim != 1 ? _offset : Offset.zero,
        duration: Durations.short1,
        child: AnimatedScale(
          scale: parallaxEnabled ? 1.1 : 1,
          duration: Durations.medium1,
          curve: Curves.fastOutSlowIn,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blur * 8, sigmaY: blur * 8),
            child: image,
          ),
        ),
      ),
    );
  }
}
