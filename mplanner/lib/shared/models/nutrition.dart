import 'package:freezed_annotation/freezed_annotation.dart';
part 'nutrition.freezed.dart';
part 'nutrition.g.dart';

@freezed
class Nutrition with _$Nutrition {
  const factory Nutrition({
    required double calories,
    required double protein,
    required double fat,
    required double carbs,
    double? fiber,
    double? sugar,
    double? sodiumMg,
  }) = _Nutrition;

  factory Nutrition.fromJson(Map<String, dynamic> json) => _$NutritionFromJson(json);
}