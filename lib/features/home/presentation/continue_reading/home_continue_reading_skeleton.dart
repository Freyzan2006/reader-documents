import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

/// The loading state for [HomeContinueReadingSection] — a placeholder
/// matching [HomeContinueReadingCard]'s rough size.
class HomeContinueReadingSkeleton extends StatelessWidget {
  const HomeContinueReadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const AppSkeleton(height: 64);
}
