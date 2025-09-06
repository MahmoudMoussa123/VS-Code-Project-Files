import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/meal_api.dart';
import '../models/meal.dart';

final mealRepositoryProvider = Provider<MealRepository>((ref) {
  return MealRepository(api: ref.watch(mealApiProvider));
});

class MealRepository {
  MealRepository({required this.api});
  final MealApi api;

  List<Meal> _cache = [];

  Future<List<Meal>> list({bool force=false}) async {
    if (_cache.isNotEmpty && !force) return _cache;
    _cache = await api.fetchMeals();
    return _cache;
  }

  Future<Meal> get(String id) async {
    if (_cache.isNotEmpty) {
      final m = _cache.where((e) => e.id == id);
      if (m.isNotEmpty) return m.first;
    }
    return api.fetchMeal(id);
  }
}