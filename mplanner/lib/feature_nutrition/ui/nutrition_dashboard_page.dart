import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/nutrition_viewmodel.dart';

class NutritionDashboardPage extends ConsumerWidget {
  const NutritionDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(dailySummaryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(nutritionProvider.notifier).logRandomSample(),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: summaries.length,
        itemBuilder: (_, i) {
          final s = summaries[i];
          return ListTile(
            title: Text('${s.day.month}/${s.day.day}  kcal ${s.calories.toStringAsFixed(0)}'),
            subtitle: Text('P ${s.protein.toStringAsFixed(0)} F ${s.fat.toStringAsFixed(0)} C ${s.carbs.toStringAsFixed(0)}'),
            trailing: Text('AvgScore ${s.avgScore.toStringAsFixed(1)}'),
          );
        },
      ),
    );
  }
}