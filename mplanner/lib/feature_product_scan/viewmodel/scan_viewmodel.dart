import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/analytics/analytics_service.dart';
import '../../../core/error/app_exception.dart';
import '../repository/product_scan_repository.dart';
import 'scan_state.dart';

final scanViewModelProvider =
    StateNotifierProvider<ScanViewModel, ScanState>((ref) {
  final repo = ref.watch(productScanRepositoryProvider);
  final analytics = ref.watch(analyticsProvider);
  return ScanViewModel(repo, analytics);
});

class ScanViewModel extends StateNotifier<ScanState> {
  ScanViewModel(this.repo, this.analytics) : super(const ScanState.idle());
  final ProductScanRepository repo;
  final AnalyticsService analytics;

  Future<void> scan(String gtin) async {
    if (gtin.isEmpty) return;
    state = const ScanState.loading();
    try {
      final product = await repo.lookup(gtin);
      state = ScanState.success(product);
      analytics.log('scan_completed', data: {
        'gtin': gtin,
        'score': product.score?.total,
        'algo': product.score?.algorithmVersion
      });
    } on AppException catch (e) {
      state = ScanState.error(e.message);
      analytics.log('scan_failed', data: {'gtin': gtin});
    } catch (e) {
      state = const ScanState.error('Unexpected error');
      analytics.log('scan_failed', data: {'gtin': gtin});
    }
  }

  void reset() => state = const ScanState.idle();
}