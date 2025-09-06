import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/meal_list_viewmodel.dart';
import 'meal_page.dart';

class MealListPage extends ConsumerWidget {
  const MealListPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(mealListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Meals')),
      body: meals.when(
        data: (list) => RefreshIndicator(
          onRefresh: () => ref.read(mealListProvider.notifier).refresh(),
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final m = list[i];
              return ListTile(
                title: Text(m.title),
                subtitle: Text('Score: ${m.aggregatedScore?.toStringAsFixed(1) ?? '-'}'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MealPage(id: m.id))),
              );
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error $e')),
      ),
    );
  }
}