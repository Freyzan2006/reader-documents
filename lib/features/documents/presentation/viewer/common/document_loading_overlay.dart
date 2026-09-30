import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

/// Overlays [banner] on a themed background, filling the nearest [Stack].
///
/// For viewer implementations whose underlying package manages its own
/// loading state with no hook to theme it (unlike pdfrx's
/// `PdfViewerParams.backgroundColor`, which already covers this for PDF) —
/// mount the format's own widget immediately so it starts loading, and stack
/// this on top until it reports ready.
class DocumentLoadingOverlay extends StatelessWidget {
  const DocumentLoadingOverlay({required this.banner, super.key});

  final Widget banner;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: ColoredBox(
          color: AppColors.of(context).background,
          child: banner,
        ),
      ),
    ],
  );
}
