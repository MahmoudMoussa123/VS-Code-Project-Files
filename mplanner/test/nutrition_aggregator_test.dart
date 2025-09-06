import 'package:flutter_test/flutter_test.dart';
import 'package:mplanner/feature_nutrition/models/nutrition_entry.dart';
import 'package:mplanner/feature_nutrition/services/nutrition_aggregator.dart';

void main() {
  test('Aggregates daily summaries', () {
    final agg = NutritionAggregator();
    final entries = [
      NutritionEntry(id: '1', consumedAt: DateTime(2024,1,1,12), calories: 300, protein: 10, fat: 5, carbs: 40, score: 70),
      NutritionEntry(id: '2', consumedAt: DateTime(2024,1,1,18), calories: 500, protein: 20, fat: 10, carbs: 60, score: 80),
    ];
    final daily = agg.summarize(entries);
    expect(daily.length, 1);
    expect(daily.first.calories, 800);
    expect(daily.first.avgScore, 75);
  });
}