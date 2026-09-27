import 'dart:async';

import 'package:flutter/foundation.dart';

class DocumentPasswordController extends ChangeNotifier {
  int _attempts = 0;
  bool _incorrect = false;
  Completer<String?>? _completer;

  bool get isPrompting => _completer != null;
  bool get incorrect => _incorrect;

  Future<String?> provide() {
    final isRetry = _attempts > 0;
    _attempts++;
    final completer = Completer<String?>();
    _completer = completer;
    _incorrect = isRetry;
    notifyListeners();
    return completer.future;
  }

  void resolve(String? password) {
    final completer = _completer;
    if (completer == null || completer.isCompleted) return;
    _completer = null;
    notifyListeners();
    completer.complete(password);
  }
}
