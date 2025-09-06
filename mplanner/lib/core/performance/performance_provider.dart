import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'performance_monitor.dart';

final performanceMonitorProvider = Provider<PerformanceMonitor>((_) => PerformanceMonitor());