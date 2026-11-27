import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';

import 'document_thumbnail.dart';

class DocumentMiniThumbnail extends StatelessWidget {
  const DocumentMiniThumbnail({required this.file, this.width = 26, super.key});

  static const _radius = BorderRadius.all(Radius.circular(3));

  final DocumentFile file;
  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: AppPageThumbnail(
      image: DocumentThumbnail.of(file),
      scanned: file.type == DocumentType.djvu,
      borderRadius: _radius,
    ),
  );
}
