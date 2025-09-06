import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/config/environment.dart';
import '../core/logging/logger.dart';
import '../core/persistence/hive_boxes.dart';

Future<ProviderScope> bootstrapApp({
  required AppEnvironment environment,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Hive
  await Hive.initFlutter();
  await openCoreHiveBoxes();

  final container = ProviderContainer(
    overrides: [
      environmentProvider.overrideWithValue(environment),
    ],
    observers: [
      RiverpodLogger(),
    ],
  );
  return ProviderScope(
    parent: container,
    child: const _BootstrapGuard(child: SizedBox()),
  );
}

class _BootstrapGuard extends StatelessWidget {
  const _BootstrapGuard({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => child;
}