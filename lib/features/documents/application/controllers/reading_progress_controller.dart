import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:reader_documents/features/documents/data/repositories/reading_offset_repository.dart';
import 'package:reader_documents/features/documents/data/repositories/reading_progress_repository.dart';

/// Restores and records where the reader left off.
///
/// Page-addressable formats (PDF) store an absolute page number. Formats
/// without stable pages (DOCX, rendered as one continuous flow) store a
/// fraction of the scrollable extent instead, which survives a different
/// screen, orientation or window size. Both are persisted under separate keys
/// so switching the mode never invalidates previously saved progress.
class ReadingProgressController extends ChangeNotifier {
  ReadingProgressController.page({
    required ReadingProgressRepository repository,
    required this.documentPath,
    this.onSaved,
  }) : _pages = repository,
       _offsets = null;

  ReadingProgressController.offset({
    required ReadingOffsetRepository repository,
    required this.documentPath,
    this.onSaved,
  }) : _pages = null,
       _offsets = repository;

  static const _saveDebounce = Duration(milliseconds: 400);

  final ReadingProgressRepository? _pages;
  final ReadingOffsetRepository? _offsets;
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
  double? _pendingFraction;

  bool _isReady = false;
  int _initialPage = 1;
  double _initialFraction = 0;

  bool get isReady => _isReady;
  int get initialPage => _initialPage;

  /// Restored scroll position in 0..1. Always 0 when [isOffsetBased].
  double get initialFraction => _initialFraction;

  /// True when this controller tracks a scroll offset rather than a page.
  bool get isOffsetBased => _offsets != null;

  Future<void> load() async {
    if (isOffsetBased) {
      final fraction = await _offsets!.load(documentPath);
      _initialFraction = (fraction ?? 0).clamp(0.0, 1.0);
    } else {
      final page = await _pages!.load(documentPath);
      _initialPage = page ?? 1;
    }
    _isReady = true;
    notifyListeners();
  }

  void onPageChanged(int? pageNumber) {
    if (isOffsetBased) return;
    if (pageNumber == null) return;
    _pendingPage = pageNumber;
    _scheduleSave();
  }

  void onScrollFraction(double fraction) {
    if (!isOffsetBased) return;
    final clamped = fraction.isFinite ? fraction.clamp(0.0, 1.0) : 0.0;
    _pendingFraction = clamped;
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
    final fraction = _pendingFraction;
    _pendingPage = null;
    _pendingFraction = null;
    if (isOffsetBased) {
      if (fraction != null) {
        // A document scrolled to its end is finished, not parked at 100%:
        // drop the key so a later open starts from the top.
        if (fraction >= 1) {
          await _offsets!.clear(documentPath);
        } else {
          await _offsets!.save(documentPath, fraction);
        }
      }
    } else if (page != null) {
      await _pages!.save(documentPath, page);
    }
    onSaved?.call();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    flush();
    super.dispose();
  }
}
