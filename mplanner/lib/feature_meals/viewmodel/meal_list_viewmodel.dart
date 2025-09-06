import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal.dart';
import '../repository/meal_repository.dart';

final mealListProvider = AsyncNotifierProvider<MealListNotifier, List<Meal>>(MealListNotifier.new);

class MealListNotifier extends AsyncNotifier<List<Meal>> {
  @override
  Future<List<Meal>> build() async {
    return ref.watch(mealRepositoryProvider).list();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(mealRepositoryProvider).list(force: true));
  }
}