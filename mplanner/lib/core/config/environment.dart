import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppEnvironment {
  const AppEnvironment({
    required this.apiBaseUrl,
    required this.flavor,
    required this.scoreAlgorithmVersion,
  });

  final String apiBaseUrl;
  final String flavor;
  final int scoreAlgorithmVersion;
}

final environmentProvider = Provider<AppEnvironment>((ref) {
  throw UnimplementedError('Environment not overridden');
});