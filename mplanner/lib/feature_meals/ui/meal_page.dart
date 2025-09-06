import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/meal_repository.dart';

class MealPage extends ConsumerWidget {
  const MealPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.watch(mealRepositoryProvider).get(id),
      builder: (_, snap) {
        if (!snap.hasData) {
          if (snap.hasError) return Scaffold(body: Center(child: Text('${snap.error}')));
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final meal = snap.data!;
        return Scaffold(
          appBar: AppBar(title: Text(meal.title)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(meal.description ?? '', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text('Score: ${meal.aggregatedScore?.toStringAsFixed(1) ?? '-'}'),
              const Divider(),
              Text('Ingredients', style: Theme.of(context).textTheme.titleMedium),
              ...meal.ingredients.map((i) => ListTile(
                dense: true,
                title: Text(i.name),
                subtitle: Text(i.quantityText ?? ''),
                trailing: Text(i.productScore?.toStringAsFixed(0) ?? '-'),
              )),
            ],
          ),
        );
      },
    );
  }
}