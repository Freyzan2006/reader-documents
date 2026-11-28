import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/features/settings/application/settings_providers.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';

import 'thumbnail/converted_pdf_thumbnail_engine.dart';
import 'thumbnail/document_thumbnail_engine.dart';
import 'thumbnail/document_thumbnail_registry.dart';
import 'thumbnail/pdf_document_thumbnail_engine.dart';

@immutable
final class DocumentPageHeroTag {
  DocumentPageHeroTag.of(DocumentFile file) : path = file.path;

  final String path;

  @override
  bool operator ==(Object other) =>
      other is DocumentPageHeroTag && other.path == path;

  @override
  int get hashCode => Object.hash(DocumentPageHeroTag, path);
}

class DocumentThumbnail extends ConsumerWidget {
  const DocumentThumbnail._({
    required this.file,
    required this.engine,
    required this.preview,
    super.key,
  });

  static DocumentThumbnailRegistry registry = DocumentThumbnailRegistry([
    const PdfDocumentThumbnailEngine(),
    ConvertedPdfThumbnailEngine(
      type: DocumentType.docx,
      projection: (context) => ProviderScope.containerOf(
        context,
        listen: false,
      ).read(docxPdfProjectionProvider),
      pdf: const PdfDocumentThumbnailEngine(),
    ),
  ]);

  static Widget? of(DocumentFile file, {bool preview = true}) {
    final engine = registry.engineFor(file.type);
    if (engine == null) return null;
    return DocumentThumbnail._(
      key: ValueKey('${file.path}:$preview'),
      file: file,
      engine: engine,
      preview: preview,
    );
  }

  final DocumentFile file;
  final DocumentThumbnailEngine engine;
  final bool preview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previews = ref.watch(
      settingsProvider.select(
        (settings) =>
            settings.value?.documentPreviews ??
            AppSettings.defaults.documentPreviews,
      ),
    );
    if (!previews.enabled(context.tokens.graphics)) {
      return const SizedBox.shrink();
    }
    return engine.build(context, file, preview: preview);
  }
}
