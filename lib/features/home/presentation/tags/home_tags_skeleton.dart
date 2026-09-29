import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

/// The loading state for [HomeTagsSection] — a handful of pill placeholders
/// matching [AppTag]'s rough shape.
class HomeTagsSkeleton extends StatelessWidget {
  const HomeTagsSkeleton({super.key});

  static const _widths = [64.0, 84.0, 56.0, 96.0];
  static const _height = 32.0;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.sm,
    children: [
      for (final width in _widths) AppSkeleton(width: width, height: _height),
    ],
  );
}
