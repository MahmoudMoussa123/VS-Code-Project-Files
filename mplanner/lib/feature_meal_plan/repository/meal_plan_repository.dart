import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../core/persistence/hive_boxes.dart';
import '../models/meal_plan.dart';

final mealPlanRepositoryProvider = Provider<MealPlanRepository>((ref) {
  final box = Hive.box<Map>(kPreferencesBox);
  return MealPlanRepository(box);
});

class MealPlanRepository {
  MealPlanRepository(this._box);
  final Box<Map> _box;
  static const _kKey = 'meal_plan_current';

  MealPlan loadOrCreate() {
    final raw = _box.get(_kKey);
    if (raw == null) {
      final monday = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
      final plan = MealPlan(weekStart: DateTime(monday.year, monday.month, monday.day));
      save(plan);
      return plan;
    }
    return MealPlan.fromJson(Map<String, dynamic>.from(raw));
  }

  void save(MealPlan plan) => _box.put(_kKey, plan.toJson());

  MealPlan add(MealPlan plan, MealPlanDayEntry entry) {
    final updated = plan.copyWith(entries: [...plan.entries, entry]);
    save(updated);
    return updated;
  }

  MealPlan remove(MealPlan plan, MealPlanDayEntry entry) {
    final updated = plan.copyWith(
      entries: plan.entries.where((e) => e != entry).toList(),
    );
    save(updated);
    return updated;
  }
}