import 'package:flutter_test/flutter_test.dart';
import 'package:mplanner/feature_alternatives/services/substitution_engine.dart';
import 'package:mplanner/feature_product_scan/models/product.dart';
import 'package:mplanner/shared/models/nutrition.dart';
import 'package:mplanner/shared/models/score.dart';

void main() {
  Product build(String id, double score) => Product(
    id: id,
    gtin: id,
    name: id,
    nutrition: const Nutrition(calories: 100, protein: 5, fat: 2, carbs: 10),
    score: Score(total: score, nutrition: score, additivesPenalty: 0, processingPenalty: 0, algorithmVersion: 1),
  );

  test('Suggests higher score products', () {
    final engine = SubstitutionEngine();
    final suggestions = engine.suggest(
      original: build('o', 60),
      pool: [build('a', 70), build('b', 65), build('c', 50)],
      minDelta: 4,
    );
    expect(suggestions.length, 2);
    expect(suggestions.first.product.id, 'a');
  });
}