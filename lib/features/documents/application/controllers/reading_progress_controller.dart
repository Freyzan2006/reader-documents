import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:reader_documents/features/documents/data/repositories/reading_progress_repository.dart';

/// Restores and records the last read page. Older DOCX scroll fractions are
/// migrated once by the viewer screen.
class ReadingProgressController extends ChangeNotifier {
  ReadingProgressController.page({
    required ReadingProgressRepository repository,
    required this.documentPath,
    this.onSaved,
  }) : _pages = repository;

  static const _saveDebounce = Duration(milliseconds: 400);

  final ReadingProgressRepository _pages;
  final String documentPath;

  /// Called after every completed write, including the one from [dispose].
  ///
  /// The home screen caches the saved value, and nothing else knows when a
  /// document has been read, so this is the signal for that cache to be
  /// dropped. Wired at the call site: the controller itself has no business
  /// knowing a home screen exists.
  final VoidCallback? onSaved;

  Timer? _saveTimer;
  int? _pendingPage;

  bool _isReady = false;
  int _initialPage = 1;

  bool get isReady => _isReady;
  int get initialPage => _initialPage;

  Future<void> load() async {
    _initialPage = await _pages.load(documentPath) ?? 1;
    _isReady = true;
    notifyListeners();
  }

  void onPageChanged(int? pageNumber) {
    if (pageNumber == null) return;
    _pendingPage = pageNumber;
    _scheduleSave();
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(_saveDebounce, flush);
  }

  /// Writes out anything still buffered, then reports back.
  ///
  /// Awaitable because callers that invalidate a cache of the saved value have
  /// to wait for the write to land, or they will re-read the previous value and
  /// keep showing it.
  Future<void> flush() async {
    final page = _pendingPage;
    _pendingPage = null;
    if (page != null) await _pages.save(documentPath, page);
    onSaved?.call();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    flush();
    super.dispose();
  }
}
