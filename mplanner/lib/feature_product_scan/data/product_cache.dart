import 'package:hive/hive.dart';

import '../../../core/persistence/hive_boxes.dart';
import '../models/product.dart';

class ProductCache {
  ProductCache(this._box);
  final Box<Map> _box;

  Future<Product?> get(String gtin) async {
    final data = _box.get(gtin);
    if (data == null) return null;
    return Product.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> put(Product product) async {
    await _box.put(product.gtin, product.toJson());
  }
}

Future<ProductCache> createProductCache() async {
  final box = Hive.box<Map>(kProductsBox);
  return ProductCache(box);
}