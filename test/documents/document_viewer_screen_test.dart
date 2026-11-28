import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/data/conversion/pdf_projection.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/features/documents/presentation/viewer/document_viewer_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_app.dart';

final class _FailingProjection implements PdfProjection {
  @override
  Future<String> pdfPathFor(DocumentFile file) async =>
      throw StateError('no pdf');
}

void main() {
  testWidgets('closing the viewer while its progress is watched', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final file = DocumentFile(
      path: '/documents/report.docx',
      name: 'report.docx',
      type: DocumentType.docx,
      sizeBytes: 1,
      modifiedAt: DateTime(2026),
    );
    final open = ValueNotifier(true);

    // Stands in for the home screen, which watches the saved page.
    await pumpTestApp(
      tester,
      Consumer(
        builder: (context, ref, _) {
          ref.watch(lastReadingProgressPageProvider(file.path));
          return ValueListenableBuilder(
            valueListenable: open,
            builder: (_, isOpen, _) =>
                isOpen ? DocumentViewerScreen(file: file) : const SizedBox(),
          );
        },
      ),
      wrapApp: (app) => ProviderScope(
        overrides: [
          docxPdfProjectionProvider.overrideWithValue(_FailingProjection()),
        ],
        child: app,
      ),
    );
    await tester.pumpAndSettle();

    open.value = false;
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
