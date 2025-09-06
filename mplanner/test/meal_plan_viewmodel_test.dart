import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:mplanner/feature_meal_plan/models/meal_plan.dart';
import 'package:mplanner/feature_meal_plan/viewmodel/meal_plan_viewmodel.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

void main() {
  setUp(() async {
    final dir = Directory.systemTemp.createTempSync();
    Hive.init(dir.path);
    await Hive.openBox<Map>('preferences_box');
  });

  test('Adds entry to meal plan', () {
    final container = ProviderContainer();
    final before = container.read(mealPlanProvider);
    expect(before.entries.length, 0);
    container.read(mealPlanProvider.notifier).addEntry(MealPlanDayEntry(
      day: DateTime.now(),
      slot: MealSlotType.lunch,
      mealId: 'meal_1',
    ));
    final after = container.read(mealPlanProvider);
    expect(after.entries.length, 1);
  });
}