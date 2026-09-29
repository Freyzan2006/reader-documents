import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

/// The loading state for [HomeStatsSection] — two placeholder tiles matching
/// [HomeStatTile]'s rough size.
class HomeStatsSkeleton extends StatelessWidget {
  const HomeStatsSkeleton({super.key});

  static const _tileHeight = 64.0;

  @override
  Widget build(BuildContext context) => const Row(
    spacing: AppSpacing.sm,
    children: [
      Expanded(child: AppSkeleton(height: _tileHeight)),
      Expanded(child: AppSkeleton(height: _tileHeight)),
    ],
  );
}
