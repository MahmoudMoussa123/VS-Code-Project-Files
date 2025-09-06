import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/feature_flags.dart';

final aiClientProvider = Provider<AiClient>((ref) {
  final flags = ref.watch(featureFlagsProvider);
  return AiClient(enabled: flags.aiExplanations);
});

class AiClient {
  AiClient({required this.enabled});
  final bool enabled;

  Future<Map<String, dynamic>> explainScore(Map<String, dynamic> payload) async {
    if (!enabled) throw StateError('AI disabled');
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'summary': 'This item scores well due to balanced protein and moderate calories.',
      'highlights': [
        'Protein supports higher nutrition sub-score',
        'Limited penalties applied (placeholder)'
      ]
    };
  }
}