import 'dart:collection';

class PerfSpan {
  PerfSpan(this.label, this.start);
  final String label;
  final DateTime start;
}

class PerformanceMonitor {
  final _stack = <PerfSpan>[];
  final List<Map<String, dynamic>> log = [];

  void start(String label) => _stack.add(PerfSpan(label, DateTime.now()));
  void end(String label) {
    final idx = _stack.lastIndexWhere((e) => e.label == label);
    if (idx == -1) return;
    final span = _stack.removeAt(idx);
    final dur = DateTime.now().difference(span.start);
    log.add({'label': label, 'ms': dur.inMilliseconds});
    if (log.length > 50) log.removeRange(0, 25);
  }

  UnmodifiableListView<Map<String, dynamic>> get entries => UnmodifiableListView(log);
}