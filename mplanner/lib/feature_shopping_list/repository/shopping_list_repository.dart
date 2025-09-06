import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../core/persistence/hive_boxes.dart';
import '../models/shopping_item.dart';
import '../../meal_plan/viewmodel/meal_plan_viewmodel.dart';

final shoppingListRepositoryProvider = Provider<ShoppingListRepository>((ref) {
  return ShoppingListRepository(Hive.box<Map>(kPreferencesBox));
});

class ShoppingListRepository {
  ShoppingListRepository(this._box);
  final Box<Map> _box;
  static const _kKey = 'shopping_list_items';

  List<ShoppingItem> load() {
    final raw = _box.get(_kKey);
    if (raw == null) return [];
    final list = (raw['items'] as List).map((e) => ShoppingItem.fromJson(Map<String, dynamic>.from(e))).toList();
    return list;
  }

  void save(List<ShoppingItem> items) => _box.put(_kKey, {'items': items.map((e) => e.toJson()).toList()});

  List<ShoppingItem> upsert(ShoppingItem item) {
    final current = load();
    final idx = current.indexWhere((i) => i.id == item.id);
    if (idx >= 0) {
      current[idx] = item;
    } else {
      current.add(item);
    }
    save(current);
    return current;
  }

  List<ShoppingItem> toggleAcquire(String id) {
    final current = load();
    final idx = current.indexWhere((i) => i.id == id);
    if (idx >= 0) {
      final it = current[idx];
      current[idx] = it.copyWith(acquired: !(it.acquired ?? false));
      save(current);
    }
    return current;
  }
}

final shoppingListProvider = NotifierProvider<ShoppingListNotifier, List<ShoppingItem>>(ShoppingListNotifier.new);

class ShoppingListNotifier extends Notifier<List<ShoppingItem>> {
  @override
  List<ShoppingItem> build() => ref.read(shoppingListRepositoryProvider).load();

  void regenerateFromPlan() {
    final plan = ref.read(mealPlanProvider);
    // Simple demo: create one aggregated item per meal entry
    final items = plan.entries
        .map((e) => ShoppingItem(
              id: '${e.mealId}-${e.slot.name}-${e.day.toIso8601String()}',
              label: 'Ingredients for ${e.mealId}',
              mealId: e.mealId,
              acquired: false,
            ))
        .toList();
    ref.read(shoppingListRepositoryProvider).save(items);
    state = items;
  }

  void toggle(String id) {
    state = ref.read(shoppingListRepositoryProvider).toggleAcquire(id);
  }
}