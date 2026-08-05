import 'package:flosu/features/audio/data/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioProvider = Provider((ref) {
  final service = AudioService();

  ref.onDispose(service.dispose);

  return service;
});
