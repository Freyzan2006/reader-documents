import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _pdfAdapters = [
  'lib/features/documents/presentation/viewer/pdf/',
  'lib/features/documents/presentation/list/thumbnail/pdf_document_thumbnail_engine.dart',
];

/// Rendering libraries must stay behind their adapters so they can be swapped.
/// Values are allowed files or directory prefixes.
const _boundaries = {
  'package:docx_creator/': [
    'lib/features/documents/data/conversion/docx_creator_pdf_converter.dart',
  ],
  'package:pdfrx/': _pdfAdapters,
  'package:syncfusion_flutter_pdf/': _pdfAdapters,
};

void main() {
  final sources = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();

  for (final MapEntry(key: library, value: allowed) in _boundaries.entries) {
    test('$library is imported only by its adapters', () {
      final violations = [
        for (final file in sources)
          if (file.readAsStringSync().contains("import '$library") &&
              !allowed.any(file.path.startsWith))
            file.path,
      ];
      expect(violations, isEmpty);
    });
  }
}
