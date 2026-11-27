import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/home/presentation/continue_reading/home_continue_reading_section.dart';
import 'package:reader_documents/features/home/presentation/recent/home_recent_section.dart';
import 'package:reader_documents/features/home/presentation/stats/home_stats_section.dart';
import 'package:reader_documents/features/home/presentation/tags/home_tags_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _gutter = EdgeInsets.symmetric(horizontal: AppSpacing.lg);

  @override
  Widget build(BuildContext context) => AppScrollArea(
    child: Padding(
      padding: EdgeInsets.only(
        top: AppHeader.topInset(context) + AppSpacing.sm,
        bottom: AppBottomNav.bottomInset(context) + AppSpacing.lg,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.lg,
        children: [
          Padding(padding: _gutter, child: HomeContinueReadingSection()),
          Padding(padding: _gutter, child: HomeStatsSection()),
          HomeRecentSection(),
          Padding(padding: _gutter, child: HomeTagsSection()),
        ],
      ),
    ),
  );
}
