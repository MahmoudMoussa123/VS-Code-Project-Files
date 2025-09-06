import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../../../core/network/dio_client.dart';

final productApiProvider = Provider<ProductApi>((ref) {
  final dio = ref.watch(dioProvider);
  return ProductApi(dio);
});

class ProductApi {
  ProductApi(this._dio);
  final Dio _dio;

  Future<Product> fetchByBarcode(String gtin) async {
    // Placeholder: Replace with actual endpoint
    final resp = await Future.delayed(
      const Duration(milliseconds: 400),
      () => {
        'id': 'local-$gtin',
        'gtin': gtin,
        'name': 'Sample Product $gtin',
        'brand': 'DemoBrand',
        'nutrition': {
          'calories': 250,
          'protein': 5,
          'fat': 10,
          'carbs': 30,
        },
        'score': 72.5,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
    return Product.fromJson(resp);
  }
}