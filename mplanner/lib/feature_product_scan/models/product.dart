import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../shared/models/nutrition.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String gtin,
    required String name,
    String? brand,
    Nutrition? nutrition,
    @JsonKey(ignore: true) Score? score, // new structured score (not persisted in stub json)
    double? scoreDeprecated,            // legacy placeholder removal later
    DateTime? updatedAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

}