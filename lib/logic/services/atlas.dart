import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flosu/core/extensions.dart';

typedef ImagePainter = void Function(Canvas canvas);

class AtlasService {
  Future<Image?> getImageFromAsset(String path) async {
    try {
      final data = await rootBundle.load(path);
      final view = Uint8List.view(data.buffer);
      final codec = await instantiateImageCodec(view);

      final frame = await codec.getNextFrame();

      return frame.image;
    } catch (err) {
      return null;
    }
  }

  Future<Image?> getImageFromCanvas(
    String path, {
    required ImagePainter painter,
  }) async {
    try {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      canvas.scale(2);

      painter(canvas);

      final rect = canvas.getLocalClipBounds();
      final picture = recorder.endRecording();

      final image = await picture.toImage(
        (rect.width * 2).ceil(),
        (rect.height * 2).ceil(),
      );

      return image;
    } catch (err) {
      "Error painting: $err".log;
      return null;
    }
  }
}

final atlasService = Provider((ref) => AtlasService());

class Drawable {
  //
}
