import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal.dart';

final mealApiProvider = Provider<MealApi>((_) => MealApi());

class MealApi {
  Future<List<Meal>> fetchMeals() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.generate(6, (i) => Meal(
      id: 'meal_$i',
      title: 'Sample Meal $i',
      prepMinutes: 10 + i,
      cookMinutes: 15 + i,
      servings: 2,
      aggregatedScore: 68 + i.toDouble(),
      ingredients: [
        MealIngredient(ingredientId: 'ing_$i', name: 'Ingredient $i', quantityText: '100g', productScore: 70+i),
      ],
    ));
  }

  Future<Meal> fetchMeal(String id) async {
    return (await fetchMeals()).firstWhere((m) => m.id == id);
  }
}