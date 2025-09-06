import 'package:flutter_test/flutter_test.dart';
import 'package:mplanner/core/services/scoring_service.dart';
import 'package:mplanner/feature_product_scan/models/product.dart';
import 'package:mplanner/shared/models/nutrition.dart';

void main() {
  test('Score computed within bounds', () {
    final service = ScoringService();
    final prod = Product(
      id: 'p1',
      gtin: '000',
      name: 'X',
      nutrition: const Nutrition(calories: 200, protein: 10, fat: 5, carbs: 20, sugar: 5),
    );
    final score = service.computeScore(prod);
    expect(score >= 0 && score <= 100, true);
  });
}