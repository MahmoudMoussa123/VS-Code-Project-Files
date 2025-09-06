import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal_plan.dart';
import '../repository/meal_plan_repository.dart';

final mealPlanProvider = NotifierProvider<MealPlanNotifier, MealPlan>(MealPlanNotifier.new);

class MealPlanNotifier extends Notifier<MealPlan> {
  @override
  MealPlan build() {
    return ref.read(mealPlanRepositoryProvider).loadOrCreate();
  }

  void addEntry(MealPlanDayEntry entry) {
    state = ref.read(mealPlanRepositoryProvider).add(state, entry);
  }

  void removeEntry(MealPlanDayEntry entry) {
    state = ref.read(mealPlanRepositoryProvider).remove(state, entry);
  }
}