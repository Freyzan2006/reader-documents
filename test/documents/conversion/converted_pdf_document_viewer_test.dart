import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/features/documents/data/conversion/pdf_projection.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/features/documents/presentation/viewer/converted/converted_pdf_document_viewer.dart';
import 'package:reader_documents/features/documents/presentation/viewer/document_viewer_factory.dart';

import '../../helpers/test_app.dart';

final _file = DocumentFile(
  path: '/documents/report.docx',
  name: 'report.docx',
  type: DocumentType.docx,
  sizeBytes: 100,
  modifiedAt: DateTime(2026),
);

final class _FailingProjection implements PdfProjection {
  @override
  Future<String> pdfPathFor(DocumentFile file) async =>
      throw StateError('broken docx');
}

Widget _errorBanner(
  BuildContext context, {
  required bool isPasswordProtected,
  required VoidCallback onBack,
}) => Text(isPasswordProtected ? 'password' : 'broken docx');

void main() {
  testWidgets('failed projection uses the standard error view', (tester) async {
    await pumpTestApp(
      tester,
      ConvertedPdfDocumentViewer(
        file: _file,
        initialPageNumber: 1,
        highlights: ValueNotifier(const []),
        onPageChanged: (_) {},
        onReady: (_) {},
        onBackgroundTap: () => true,
        passwordProvider: () async => null,
        buildContextMenu: (_, _, _) => null,
        buildMagnifier: (_, content, _) => content,
        buildErrorBanner: _errorBanner,
        buildLoadingBanner: (_) => const Text('loading'),
        projection: _FailingProjection(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('broken docx'), findsOneWidget);
    expect(find.text('password'), findsNothing);
  });

  test('factory renders DOCX through its PDF projection', () {
    final viewer = DocumentViewerFactory.build(
      file: _file,
      initialPageNumber: 1,
      highlights: ValueNotifier(const []),
      onPageChanged: (_) {},
      onReady: (_) {},
      onBackgroundTap: () => true,
      passwordProvider: () async => null,
      buildContextMenu: (_, _, _) => null,
      buildMagnifier: (_, content, _) => content,
      buildErrorBanner: _errorBanner,
      buildLoadingBanner: (_) => const SizedBox.shrink(),
      docxPdfProjection: _FailingProjection(),
    );

    expect(viewer, isA<ConvertedPdfDocumentViewer>());
  });
}
