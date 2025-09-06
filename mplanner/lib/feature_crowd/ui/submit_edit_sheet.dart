import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/edit_queue_viewmodel.dart';

class SubmitEditSheet extends ConsumerStatefulWidget {
  const SubmitEditSheet({super.key, required this.gtin});
  final String gtin;

  @override
  ConsumerState<SubmitEditSheet> createState() => _SubmitEditSheetState();
}

class _SubmitEditSheetState extends ConsumerState<SubmitEditSheet> {
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Propose Edit for ${widget.gtin}', style: Theme.of(context).textTheme.titleMedium),
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'New Name')),
          TextField(controller: _brandCtrl, decoration: const InputDecoration(labelText: 'New Brand')),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              final changes = <String, dynamic>{};
              if (_nameCtrl.text.trim().isNotEmpty) changes['name'] = _nameCtrl.text.trim();
              if (_brandCtrl.text.trim().isNotEmpty) changes['brand'] = _brandCtrl.text.trim();
              ref.read(editQueueProvider.notifier).submit(widget.gtin, changes);
              Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}