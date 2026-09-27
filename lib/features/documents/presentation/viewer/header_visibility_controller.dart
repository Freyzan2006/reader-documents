import 'dart:async';

import 'package:flutter/foundation.dart';

class HeaderVisibilityController extends ChangeNotifier {
  static const _autoHideDelay = Duration(seconds: 3);

  bool _visible = true;
  Timer? _autoHideTimer;

  bool get visible => _visible;

  void scheduleAutoHide() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(_autoHideDelay, () {
      _visible = false;
      notifyListeners();
    });
  }

  void cancelAutoHide() => _autoHideTimer?.cancel();

  void toggle() {
    _visible = !_visible;
    notifyListeners();
    if (_visible) {
      scheduleAutoHide();
    } else {
      _autoHideTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    super.dispose();
  }
}
