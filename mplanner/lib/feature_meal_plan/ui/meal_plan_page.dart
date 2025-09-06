import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal_plan.dart';
import '../viewmodel/meal_plan_viewmodel.dart';

class MealPlanPage extends ConsumerWidget {
  const MealPlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(mealPlanProvider);
    final grouped = <DateTime, List<MealPlanDayEntry>>{};
    for (final e in plan.entries) {
      final day = DateTime(e.day.year, e.day.month, e.day.day);
      grouped.putIfAbsent(day, () => []).add(e);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Meal Plan')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _add(context, ref),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: grouped.keys.toList()
          ..sort()
          ..map((d) => d).map((day) {
            final entries = grouped[day]!;
            return ExpansionTile(
              title: Text('${day.month}/${day.day}'),
              children: entries
                  .map((e) => ListTile(
                        title: Text(e.mealId),
                        subtitle: Text(e.slot.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => ref.read(mealPlanProvider.notifier).removeEntry(e),
                        ),
                      ))
                  .toList(),
            );
          }).toList(),
      ),
    );
  }

  void _add(BuildContext ctx, WidgetRef ref) {
    final mealIdCtrl = TextEditingController();
    MealSlotType slot = MealSlotType.dinner;
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Add Meal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: mealIdCtrl, decoration: const InputDecoration(labelText: 'Meal ID')),
            DropdownButton<MealSlotType>(
              value: slot,
              onChanged: (v) {
                if (v == null) return;
                slot = v;
              },
              items: MealSlotType.values
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(mealPlanProvider.notifier).addEntry(MealPlanDayEntry(
                    day: DateTime.now(),
                    slot: slot,
                    mealId: mealIdCtrl.text.trim(),
                  ));
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }
}