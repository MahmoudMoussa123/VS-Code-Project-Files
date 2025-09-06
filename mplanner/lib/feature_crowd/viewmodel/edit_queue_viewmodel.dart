import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/edit_submission.dart';
import '../repository/edit_queue_repository.dart';

final editQueueProvider = NotifierProvider<EditQueueNotifier, List<EditSubmission>>(EditQueueNotifier.new);

class EditQueueNotifier extends Notifier<List<EditSubmission>> {
  @override
  List<EditSubmission> build() => ref.read(editQueueRepositoryProvider).load();

  void submit(String gtin, Map<String, dynamic> changes) {
    final uuid = const Uuid().v4();
    final sub = EditSubmission(
      id: uuid,
      productGtIn: gtin,
      proposedChanges: changes,
      status: EditStatus.pending,
      createdAt: DateTime.now(),
    );
    state = ref.read(editQueueRepositoryProvider).add(sub);
  }

  Future<void> sync() async {
    // Mock sync: mark all pending as submitted
    await Future.delayed(const Duration(milliseconds: 300));
    for (final s in state.where((e) => e.status == EditStatus.pending)) {
      state = ref.read(editQueueRepositoryProvider).markSubmitted(s.id);
    }
  }
}