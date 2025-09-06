import 'package:freezed_annotation/freezed_annotation.dart';
part 'nutrition_entry.freezed.dart';
part 'nutrition_entry.g.dart';

@freezed
class NutritionEntry with _$NutritionEntry {
  const factory NutritionEntry({
    required String id,
    required DateTime consumedAt,
    required double calories,
    required double protein,
    required double fat,
    required double carbs,
    double? score,
    String? refId,
    String? refType, // meal|product
  }) = _NutritionEntry;

  factory NutritionEntry.fromJson(Map<String, dynamic> json) => _$NutritionEntryFromJson(json);
}

@freezed
class DailySummary with _$DailySummary {
  const factory DailySummary({
    required DateTime day,
    required double calories,
    required double protein,
    required double fat,
    required double carbs,
    required double avgScore,
  }) = _DailySummary;
}