import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';

import '../../application/documents_providers.dart';
import 'document_thumbnail.dart';

class DocumentCompactCard extends ConsumerWidget {
  const DocumentCompactCard({required this.file, this.onTap, super.key});

  static const _width = 112.0;

  final DocumentFile file;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SizedBox(
    width: _width,
    child: AppDocumentCard(
      title: ref.watch(documentTitleProvider(file.path)) ?? file.name,
      meta: file.formattedSize,
      format: file.type.label,
      favorite: ref.watch(isFavoriteProvider(file.path)),
      scanned: file.type == DocumentType.djvu,
      progress: ref.watch(readingFractionProvider(file.path)),
      thumbnail: DocumentThumbnail.of(file),
      onTap: onTap,
    ),
  );
}
