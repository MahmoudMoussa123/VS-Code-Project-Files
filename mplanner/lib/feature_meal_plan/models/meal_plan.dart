import 'package:freezed_annotation/freezed_annotation.dart';
part 'meal_plan.freezed.dart';
part 'meal_plan.g.dart';

enum MealSlotType { breakfast, lunch, dinner, snack }

@freezed
class MealPlanDayEntry with _$MealPlanDayEntry {
  const factory MealPlanDayEntry({
    required DateTime day,
    required MealSlotType slot,
    required String mealId,
  }) = _MealPlanDayEntry;

  factory MealPlanDayEntry.fromJson(Map<String, dynamic> json) => _$MealPlanDayEntryFromJson(json);
}

@freezed
class MealPlan with _$MealPlan {
  const factory MealPlan({
    required DateTime weekStart, // Monday
    @Default([]) List<MealPlanDayEntry> entries,
  }) = _MealPlan;

  factory MealPlan.fromJson(Map<String, dynamic> json) => _$MealPlanFromJson(json);
}