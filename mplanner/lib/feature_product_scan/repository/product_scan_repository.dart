import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/services/scoring_service.dart';
import '../data/product_api.dart';
import '../data/product_cache.dart';
import '../models/product.dart';

final productScanRepositoryProvider = Provider<ProductScanRepository>((ref) {
  final api = ref.watch(productApiProvider);
  final cache = ref.watch(_productCacheProvider);
  final scorer = ref.watch(scoringServiceProvider);
  return ProductScanRepository(api: api, cache: cache, scoring: scorer);
});

final _productCacheProvider = Provider<ProductCache>((ref) {
  // Hive already opened at bootstrap
  // ignore: avoid_print
  return ProductCache(Hive.box<Map>('products_box'));
});

class ProductScanRepository {
  ProductScanRepository({required this.api, required this.cache, required this.scoring});
  final ProductApi api;
  final ProductCache cache;
  final ScoringService scoring;

  Future<Product> lookup(String gtin) async {
    final cached = await cache.get(gtin);
    if (cached != null) {
      final scored = cached.score ?? scoring.compute(cached);
      return cached.copyWith(score: scored);
    }
    final fresh = await api.fetchByBarcode(gtin);
    final scored = scoring.compute(fresh);
    final toStore = fresh.copyWith(scoreDeprecated: scored.total); // minimal stub persisted
    await cache.put(toStore);
    return toStore.copyWith(score: scored);
  }
}