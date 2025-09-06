import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/environment.dart';
import '../feature_auth/viewmodel/auth_viewmodel.dart';
import '../feature_auth/ui/login_page.dart';
import '../feature_product_scan/ui/scan_page.dart';
import 'home_shell.dart';

class AppWidget extends ConsumerWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final env = ref.watch(environmentProvider);
    final auth = ref.watch(authViewModelProvider);
    return MaterialApp(
      title: 'mPlanner (${env.flavor})',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: auth.maybeWhen(
        authenticated: (_) => const HomeShell(),
        orElse: () => const LoginPage(),
      ),
    );
  }
}
