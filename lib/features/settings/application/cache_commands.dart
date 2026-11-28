import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reader_documents/core/storage/app_cache.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/providers/documents_providers.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

final appCacheProvider = Provider<AppCache>(
  (ref) =>
      const DirectoryAppCache([docxPdfCacheDirectory, getTemporaryDirectory]),
);

final cacheSizeProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.watch(appCacheProvider).size(),
);

abstract final class CacheCommands {
  static Future<void> clear(BuildContext context, WidgetRef ref) async {
    final freed = await ref.read(appCacheProvider).clear();
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
    ref.invalidate(cacheSizeProvider);
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    AppToast.show(
      context: context,
      title: Text(
        freed > 0
            ? l10n.cacheClearedToast(DocumentFile.formatBytes(freed))
            : l10n.cacheAlreadyEmptyToast,
      ),
    );
  }
}
