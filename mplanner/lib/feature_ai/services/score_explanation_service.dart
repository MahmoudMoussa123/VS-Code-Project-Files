import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/score.dart';
import '../../product_scan/models/product.dart';
import 'ai_client.dart';

final scoreExplanationServiceProvider = Provider<ScoreExplanationService>((ref) {
  return ScoreExplanationService(client: ref.watch(aiClientProvider));
});

class ScoreExplanation {
  ScoreExplanation(this.summary, this.highlights, {this.ai = false});
  final String summary;
  final List<String> highlights;
  final bool ai;
}

class ScoreExplanationService {
  ScoreExplanationService({required this.client});
  final AiClient client;

  Future<ScoreExplanation> explain(Product product) async {
    final s = product.score;
    if (s == null) {
      return ScoreExplanation('Score data missing.', const [], ai: false);
    }
    try {
      final ai = await client.explainScore({
        'nutrition': s.nutrition,
        'additivesPenalty': s.additivesPenalty,
        'processingPenalty': s.processingPenalty,
        'total': s.total
      });
      return ScoreExplanation(
        ai['summary'] as String,
        (ai['highlights'] as List).cast<String>(),
        ai: true,
      );
    } catch (_) {
      // Fallback deterministic
      final summary =
          'Base nutrition score ${s.nutrition.toStringAsFixed(1)} minus penalties ${(s.additivesPenalty + s.processingPenalty).toStringAsFixed(1)} gives total ${s.total.toStringAsFixed(1)}.';
      return ScoreExplanation(summary, [
        'Nutrition component: ${s.nutrition.toStringAsFixed(1)}',
        'Additives penalty: ${s.additivesPenalty.toStringAsFixed(1)}',
        'Processing penalty: ${s.processingPenalty.toStringAsFixed(1)}'
      ]);
    }
  }
}