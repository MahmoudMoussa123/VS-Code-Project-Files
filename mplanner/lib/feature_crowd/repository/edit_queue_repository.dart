import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/persistence/hive_boxes.dart';
import '../models/edit_submission.dart';

final editQueueRepositoryProvider = Provider<EditQueueRepository>((_) {
  return EditQueueRepository(Hive.box<Map>(kPreferencesBox));
});

class EditQueueRepository {
  EditQueueRepository(this._box);
  final Box<Map> _box;
  static const _kKey = 'edit_queue';

  List<EditSubmission> load() {
    final raw = _box.get(_kKey);
    if (raw == null) return [];
    return (raw['list'] as List)
        .map((e) => EditSubmission.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  void save(List<EditSubmission> list) => _box.put(_kKey, {'list': list.map((e) => e.toJson()).toList()});

  List<EditSubmission> add(EditSubmission sub) {
    final list = load()..add(sub);
    save(list);
    return list;
  }

  List<EditSubmission> markSubmitted(String id) {
    final list = load();
    final idx = list.indexWhere((e) => e.id == id);
    if (idx >= 0) list[idx] = list[idx].copyWith(status: EditStatus.submitted);
    save(list);
    return list;
  }
}