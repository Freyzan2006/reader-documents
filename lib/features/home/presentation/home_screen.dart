import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/home/presentation/continue_reading/home_continue_reading_section.dart';
import 'package:reader_documents/features/home/presentation/favorites/home_favorites_section.dart';
import 'package:reader_documents/features/home/presentation/quick_actions/home_quick_actions.dart';
import 'package:reader_documents/features/home/presentation/recent/home_recent_section.dart';
import 'package:reader_documents/features/home/presentation/stats/home_stats_section.dart';
import 'package:reader_documents/features/home/presentation/tags/home_tags_section.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppScrollArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppHeader.topInset(context) + AppSpacing.lg,
          AppSpacing.lg,
          AppBottomNav.bottomInset(context) + AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.xl,
          children: [
            AppText(l10n.homeTitle, variant: AppTextVariant.title),
            const HomeStatsSection(),
            const HomeQuickActions(),
            const HomeContinueReadingSection(),
            const HomeFavoritesSection(),
            const HomeTagsSection(),
            const HomeRecentSection(),
          ],
        ),
      ),
    );
  }
}
