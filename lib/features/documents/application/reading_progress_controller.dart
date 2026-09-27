import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:reader_documents/features/documents/data/reading_progress_repository.dart';

class ReadingProgressController extends ChangeNotifier {
  ReadingProgressController(this._repository, this._documentPath);

  static const _saveDebounce = Duration(milliseconds: 400);

  final ReadingProgressRepository _repository;
  final String _documentPath;

  Timer? _saveTimer;
  int? _pendingPage;

  bool _isReady = false;
  int _initialPage = 1;

  bool get isReady => _isReady;
  int get initialPage => _initialPage;

  Future<void> load() async {
    final page = await _repository.loadPage(_documentPath);
    _initialPage = page ?? 1;
    _isReady = true;
    notifyListeners();
  }

  void onPageChanged(int? pageNumber) {
    if (pageNumber == null) return;
    _pendingPage = pageNumber;
    _saveTimer?.cancel();
    _saveTimer = Timer(_saveDebounce, _flushPendingPage);
  }

  void _flushPendingPage() {
    final page = _pendingPage;
    if (page == null) return;
    _pendingPage = null;
    _repository.savePage(_documentPath, page);
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _flushPendingPage();
    super.dispose();
  }
}
