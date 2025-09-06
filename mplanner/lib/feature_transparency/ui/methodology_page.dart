import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/environment.dart';

class MethodologyPage extends ConsumerWidget {
  const MethodologyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final env = ref.watch(environmentProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Health Score Methodology')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Algorithm Version: ${env.scoreAlgorithmVersion}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            const Text(
              'Current score combines nutrition balance minus additive and processing penalties. '
              'Future versions add personalized adjustments and refined risk weighting.',
            ),
            const SizedBox(height: 16),
            const Text('Components:'),
            const Text('- Nutrition component (macro-based)'),
            const Text('- Additives penalty (placeholder fixed)'),
            const Text('- Processing penalty (placeholder fixed)'),
          ],
        ),
      ),
    );
  }
}