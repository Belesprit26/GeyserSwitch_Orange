import 'package:flutter/foundation.dart';

class Log {
  static void d(String message) {
    if (kDebugMode) debugPrint(message);
  }

  static void e(Object error, [StackTrace? stackTrace, String? context]) {
    final ctx = context != null ? ' [$context]' : '';
    debugPrint('Error$ctx: $error');
    if (stackTrace != null) debugPrint(stackTrace.toString());
  }
}


