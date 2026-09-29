import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../home_section.dart';
import '../home_section_error_banner.dart';
import 'home_tags_chips.dart';
import 'home_tags_skeleton.dart';

/// Every known tag as a chip; tapping one jumps to the Documents tab
/// filtered to it. Hides itself when no tags have been defined yet.
class HomeTagsSection extends ConsumerWidget {
  const HomeTagsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return ref
        .watch(tagDefinitionsProvider)
        .when(
          data: (tags) => tags.isEmpty
              ? const SizedBox.shrink()
              : HomeSection(
                  title: l10n.homeTagsTitle,
                  icon: AppIcons.tags,
                  child: HomeTagsChips(tags: tags),
                ),
          loading: () => HomeSection(
            title: l10n.homeTagsTitle,
            icon: AppIcons.tags,
            child: const HomeTagsSkeleton(),
          ),
          error: (error, _) => HomeSection(
            title: l10n.homeTagsTitle,
            icon: AppIcons.tags,
            child: HomeSectionErrorBanner(
              message: l10n.homeTagsLoadError,
              error: error,
            ),
          ),
        );
  }
}
