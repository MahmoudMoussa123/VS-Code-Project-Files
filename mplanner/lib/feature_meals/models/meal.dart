import 'package:freezed_annotation/freezed_annotation.dart';
part 'meal.freezed.dart';
part 'meal.g.dart';

@freezed
class Meal with _$Meal {
  const factory Meal({
    required String id,
    required String title,
    String? description,
    int? prepMinutes,
    int? cookMinutes,
    int? servings,
    double? aggregatedScore,
    @Default([]) List<MealIngredient> ingredients,
  }) = _Meal;

  factory Meal.fromJson(Map<String,dynamic> json) => _$MealFromJson(json);
}

@freezed
class MealIngredient with _$MealIngredient {
  const factory MealIngredient({
    required String ingredientId,
    required String name,
    String? quantityText,
    double? productScore,
  }) = _MealIngredient;

  factory MealIngredient.fromJson(Map<String,dynamic> json) => _$MealIngredientFromJson(json);
}