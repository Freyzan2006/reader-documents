import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/widgets.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/features/documents/data/models/document_highlight.dart';

import 'document_text_selection.dart';
import 'document_viewer_controller.dart';

typedef DocumentPasswordProvider = Future<String?> Function();

typedef DocumentContextMenuBuilder = Widget? Function(
  BuildContext context,
  DocumentTextSelection selection,
  VoidCallback dismiss,
);

typedef DocumentMagnifierBuilder = Widget Function(
  BuildContext context,
  Widget content,
  Size contentSize,
);

typedef DocumentErrorBannerBuilder = Widget Function(
  BuildContext context, {
  required bool isPasswordProtected,
  required VoidCallback onBack,
});

typedef DocumentLoadingBannerBuilder = Widget Function(BuildContext context);

typedef DocumentBackgroundTapHandler = bool Function();

abstract class DocumentViewer extends StatefulWidget {
  const DocumentViewer({
    required this.file,
    required this.initialPageNumber,
    required this.highlights,
    required this.onPageChanged,
    required this.onReady,
    required this.onBackgroundTap,
    required this.passwordProvider,
    required this.buildContextMenu,
    required this.buildMagnifier,
    required this.buildErrorBanner,
    required this.buildLoadingBanner,
    this.initialReadFraction = 0,
    this.onReadFractionChanged,
    super.key,
  });

  final DocumentFile file;
  final int initialPageNumber;
  final ValueListenable<List<DocumentHighlight>> highlights;
  final ValueChanged<int?> onPageChanged;

  /// Restored reading position in 0..1, for formats with no addressable page
  /// numbers. Ignored by viewers that paginate.
  final double initialReadFraction;

  /// Reports the live reading position in 0..1. Null in viewers that paginate,
  /// where [onPageChanged] carries the position instead.
  final ValueChanged<double>? onReadFractionChanged;
  final ValueChanged<DocumentViewerController> onReady;
  final DocumentBackgroundTapHandler onBackgroundTap;
  final DocumentPasswordProvider passwordProvider;
  final DocumentContextMenuBuilder buildContextMenu;
  final DocumentMagnifierBuilder buildMagnifier;
  final DocumentErrorBannerBuilder buildErrorBanner;
  final DocumentLoadingBannerBuilder buildLoadingBanner;
}
