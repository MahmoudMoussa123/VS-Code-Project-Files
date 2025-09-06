import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/shopping_list_repository.dart';

class ShoppingListPage extends ConsumerWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(shoppingListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(shoppingListProvider.notifier).regenerateFromPlan(),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (_, i) {
          final it = items[i];
            return CheckboxListTile(
            value: it.acquired ?? false,
            onChanged: (_) => ref.read(shoppingListProvider.notifier).toggle(it.id),
            title: Text(it.label),
            subtitle: Text(it.mealId ?? ''),
          );
        },
      ),
    );
  }
}