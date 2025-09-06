import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsProvider = Provider<AnalyticsService>((_) => AnalyticsService());

class AnalyticsService {
  final List<Map<String, dynamic>> _buffer = [];
  void log(String event, {Map<String, dynamic>? data}) {
    _buffer.add({'event': event, 'data': data, 'ts': DateTime.now().toIso8601String()});
    if (_buffer.length >= 10) flush();
  }

  void flush() {
    // ignore: avoid_print
    for (final e in _buffer) { print('[ANALYTICS] $e'); }
    _buffer.clear();
  }
}