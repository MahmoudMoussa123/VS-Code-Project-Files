import '../models/nutrition_entry.dart';

class NutritionAggregator {
  List<DailySummary> summarize(List<NutritionEntry> entries) {
    final map = <DateTime, List<NutritionEntry>>{};
    for (final e in entries) {
      final key = DateTime(e.consumedAt.year, e.consumedAt.month, e.consumedAt.day);
      map.putIfAbsent(key, () => []).add(e);
    }
    return map.entries.map((kv) {
      final list = kv.value;
      double calories = 0, protein = 0, fat = 0, carbs = 0, scoreSum = 0;
      int scoreCount = 0;
      for (final e in list) {
        calories += e.calories;
        protein += e.protein;
        fat += e.fat;
        carbs += e.carbs;
        if (e.score != null) {
          scoreSum += e.score!;
          scoreCount++;
        }
      }
      return DailySummary(
        day: kv.key,
        calories: calories,
        protein: protein,
        fat: fat,
        carbs: carbs,
        avgScore: scoreCount == 0 ? 0 : scoreSum / scoreCount,
      );
    }).toList()
      ..sort((a, b) => b.day.compareTo(a.day));
  }
}