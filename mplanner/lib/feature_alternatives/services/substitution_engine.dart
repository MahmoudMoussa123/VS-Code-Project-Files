import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../feature_product_scan/models/product.dart';

final substitutionEngineProvider = Provider<SubstitutionEngine>((_) => SubstitutionEngine());

class SubstitutionResult {
  SubstitutionResult(this.product, this.deltaScore);
  final Product product;
  final double deltaScore;
}

class SubstitutionEngine {
  List<SubstitutionResult> suggest({
    required Product original,
    required List<Product> pool,
    double minDelta = 5,
  }) {
    return pool
        .where((p) => p.score != null && original.score != null && (p.score! - original.score!) >= minDelta)
        .map((p) => SubstitutionResult(p, p.score! - (original.score ?? 0)))
        .toList()
      ..sort((a,b) => b.deltaScore.compareTo(a.deltaScore));
  }
}