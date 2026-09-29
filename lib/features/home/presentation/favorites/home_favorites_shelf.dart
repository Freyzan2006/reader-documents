import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/features/documents/presentation/actions/document_commands.dart';
import 'package:reader_documents/features/documents/presentation/list/document_compact_card.dart';

/// The loaded-data rendering for [HomeFavoritesSection] — a horizontally
/// scrolling shelf of favorited documents.
///
/// `IntrinsicHeight` + a horizontally-scrolling `Row` (rather than a
/// fixed-height `SizedBox` + `ListView`) so the shelf always matches
/// whatever height [DocumentCompactCard] actually needs — no magic number
/// to keep in sync with that card's content, so it can't drift out of date
/// if the card's design changes or the system text scale grows.
class HomeFavoritesShelf extends ConsumerWidget {
  const HomeFavoritesShelf({required this.favorites, super.key});

  final List<DocumentFile> favorites;

  @override
  Widget build(BuildContext context, WidgetRef ref) => IntrinsicHeight(
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: AppSpacing.sm,
        children: [
          for (final file in favorites)
            DocumentCompactCard(
              file: file,
              onTap: () => DocumentCommands.open(context, ref, file),
            ),
        ],
      ),
    ),
  );
}
