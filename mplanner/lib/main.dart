import 'package:flutter/material.dart';
import 'app/app_bootstrap.dart';
import 'app/app_widget.dart';
import 'core/config/environment.dart';

Future<void> main() async {
  // Could inject via --dart-define in later steps.
  final env = AppEnvironment(
    apiBaseUrl: const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.dev.local'),
    flavor: const String.fromEnvironment('BUILD_ENV', defaultValue: 'dev'),
    scoreAlgorithmVersion: int.tryParse(const String.fromEnvironment('SCORE_ALGO_VERSION', defaultValue: '1')) ?? 1,
  );

  final scope = await bootstrapApp(environment: env);
  runApp(scope.copyWith(child: const AppWidget()));
}
