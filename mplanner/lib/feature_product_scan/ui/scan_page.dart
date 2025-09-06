import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../viewmodel/scan_viewmodel.dart';
import 'widgets/score_badge.dart';
import '../../crowd/ui/submit_edit_sheet.dart';
import '../../ai/services/score_explanation_service.dart';

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  final _manualCtrl = TextEditingController();
  bool _camera = false;
  String? _last;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scanViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan'),
        actions: [
          IconButton(
            icon: Icon(_camera ? Icons.stop : Icons.camera),
            onPressed: () => setState(() => _camera = !_camera),
          )
        ],
      ),
      body: Column(
        children: [
          if (_camera)
            SizedBox(
              height: 220,
              child: MobileScanner(
                onDetect: (capture) {
                  final code = capture.barcodes.first.rawValue;
                  if (code != null && code != _last) {
                    _last = code;
                    ref.read(scanViewModelProvider.notifier).scan(code);
                  }
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _manualCtrl,
                    decoration: const InputDecoration(labelText: 'Manual barcode'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => ref.read(scanViewModelProvider.notifier).scan(_manualCtrl.text.trim()),
                  child: const Text('Scan'),
                )
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: state.when(
                idle: () => const Text('Awaiting scan'),
                loading: () => const CircularProgressIndicator(),
                success: (p) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(p.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ScoreBadge(score: p.score),
                    const SizedBox(height: 4),
                    Text('GTIN: ${p.gtin}'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            showModalBottomSheet(
                              builder: (_) => SubmitEditSheet(gtin: p.gtin),
                              isScrollControlled: true,
                              context: context,
                            );
                          },
                          child: const Text('Suggest Edit'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final exp = await ref.read(scoreExplanationServiceProvider).explain(p);
                            if (!mounted) return;
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text('Score Explanation${exp.ai ? " (AI)" : ""}'),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ...exp.highlights.map((h) => Text('• $h')),
                                    const SizedBox(height: 8),
                                    Text(exp.summary),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text('Explain'),
                        ),
                      ],
                    ),
                  ],
                ),
                error: (m) => Text(m, style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}