import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/product.dart';

part 'scan_state.freezed.dart';

@freezed
class ScanState with _$ScanState {
  const factory ScanState.idle() = _Idle;
  const factory ScanState.loading() = _Loading;
  const factory ScanState.success(Product product) = _Success;
  const factory ScanState.error(String message) = _Error;
}