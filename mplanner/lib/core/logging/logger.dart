import 'package:flutter_riverpod/flutter_riverpod.dart';

class RiverpodLogger extends ProviderObserver {
  @override
  void didUpdateProvider(ProviderBase provider, Object? previousValue, Object? newValue, ProviderContainer container) {
    // Basic debug logging; swap for proper logger or Sentry breadcrumbs later.
    // ignore: avoid_print
    print('[PROVIDER] ${provider.name ?? provider.runtimeType} -> $newValue');
  }
}