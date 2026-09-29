import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../home_section.dart';
import '../home_section_error_banner.dart';
import 'home_favorites_shelf.dart';
import 'home_favorites_skeleton.dart';

/// A horizontal shelf of favorited documents. Hides itself when there are
/// none.
class HomeFavoritesSection extends ConsumerWidget {
  const HomeFavoritesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return ref
        .watch(favoriteDocumentsProvider)
        .when(
          data: (favorites) => favorites.isEmpty
              ? const SizedBox.shrink()
              : HomeSection(
                  title: l10n.homeFavoritesTitle,
                  icon: AppIcons.star,
                  child: HomeFavoritesShelf(favorites: favorites),
                ),
          loading: () => HomeSection(
            title: l10n.homeFavoritesTitle,
            icon: AppIcons.star,
            child: const HomeFavoritesSkeleton(),
          ),
          error: (error, _) => HomeSection(
            title: l10n.homeFavoritesTitle,
            icon: AppIcons.star,
            child: HomeSectionErrorBanner(
              message: l10n.documentsLoadError,
              error: error,
            ),
          ),
        );
  }
}
