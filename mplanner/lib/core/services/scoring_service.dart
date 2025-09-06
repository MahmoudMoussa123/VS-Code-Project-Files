import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/score.dart';
import '../../feature_product_scan/models/product.dart';
import '../config/environment.dart';

final scoringServiceProvider = Provider<ScoringService>((ref) {
  final algo = ref.watch(environmentProvider).scoreAlgorithmVersion;
  return ScoringService(algoVersion: algo);
});

class ScoringService {
  ScoringService({required this.algoVersion});
  final int algoVersion;

  Score compute(Product p) {
    final n = p.nutrition;
    final nutritionScore = _nutritionComponent(n);
    final additivesPenalty = 5; // placeholder (later risk analysis)
    final processingPenalty = 3;
    final total = (nutritionScore - additivesPenalty - processingPenalty).clamp(0, 100).toDouble();
    return Score(
      total: total,
      nutrition: nutritionScore,
      additivesPenalty: additivesPenalty.toDouble(),
      processingPenalty: processingPenalty.toDouble(),
      algorithmVersion: algoVersion,
      calculatedAt: DateTime.now(),
    );
  }

  double _nutritionComponent(n) {
    if (n == null) return 50;
    // naive scoring weighting protein up, sugars/fat down
    final base = 60 +
        (n.protein * 0.8) -
        (n.fat * 0.3) -
        ((n.sugar ?? 8) * 0.4);
    return base.clamp(0, 100);
  }
}