import 'package:flosu/features/audio_experimental/data/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioProvider = Provider((ref) {
  final service = ExperimentalAudioService();

  ref.onDispose(service.dispose);
  return service;
});
