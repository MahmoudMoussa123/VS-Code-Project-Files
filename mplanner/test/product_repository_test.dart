import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mplanner/feature_product_scan/repository/product_scan_repository.dart';
import 'package:mplanner/feature_product_scan/data/product_api.dart';

void main() {
  test('Product repository returns mock product', () async {
    final container = ProviderContainer();
    final repo = container.read(productScanRepositoryProvider);
    final p = await repo.lookup('12345');
    expect(p.gtin, '12345');
    expect(p.name.contains('Sample Product'), true);
  });
}