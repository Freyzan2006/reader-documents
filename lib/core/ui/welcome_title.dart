import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

/// A reusable welcome title for main screens.
class WelcomeTitle extends StatelessWidget {
  const WelcomeTitle({
    required this.title,
    this.personalizedTitle,
    super.key,
  });

  /// Default title when no personalization is available.
  final String title;

  /// Personalized title (e.g. with user's first name). When non-null and
  /// non-empty, it takes precedence over [title].
  final String? personalizedTitle;

  @override
  Widget build(BuildContext context) {
    final displayTitle = personalizedTitle ?? title;
    return AppText(displayTitle, variant: AppTextVariant.title);
  }
}
