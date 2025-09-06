import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final crashReporterProvider = Provider<CrashReporter>((_) => CrashReporter());

class CrashReporter {
  void recordError(Object error, StackTrace stack, {String? context}) {
    // ignore: avoid_print
    print('[CRASH] $context $error\n$stack');
  }
}

void installGlobalCrashHandler(CrashReporter reporter) {
  FlutterError.onError = (details) {
    reporter.recordError(details.exception, details.stack ?? StackTrace.current, context: 'FlutterError');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    reporter.recordError(error, stack, context: 'Zone');
    return true;
  };
}