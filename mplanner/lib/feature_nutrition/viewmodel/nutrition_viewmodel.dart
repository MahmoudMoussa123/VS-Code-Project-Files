import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../core/persistence/hive_boxes.dart';
import '../models/nutrition_entry.dart';
import '../services/nutrition_aggregator.dart';

final nutritionProvider = NotifierProvider<NutritionNotifier, List<NutritionEntry>>(NutritionNotifier.new);
final dailySummaryProvider = Provider<List<DailySummary>>((ref) {
  final entries = ref.watch(nutritionProvider);
  return NutritionAggregator().summarize(entries);
});

class NutritionNotifier extends Notifier<List<NutritionEntry>> {
  @override
  List<NutritionEntry> build() {
    final box = Hive.box<Map>(kPreferencesBox).get('nutrition_entries');
    if (box == null) return [];
    return (box['list'] as List)
        .map((e) => NutritionEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  void _persist() {
    Hive.box<Map>(kPreferencesBox)
        .put('nutrition_entries', {'list': state.map((e) => e.toJson()).toList()});
  }

  void logRandomSample() {
    final now = DateTime.now();
    final entry = NutritionEntry(
      id: 'n-${now.millisecondsSinceEpoch}',
      consumedAt: now,
      calories: 400 + Random().nextInt(200),
      protein: 20,
      fat: 10,
      carbs: 50,
      score: 70 + Random().nextInt(10).toDouble(),
    );
    state = [...state, entry];
    _persist();
  }
}