import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/features/documents/data/conversion/fonts/asset_font_library.dart';
import 'package:reader_documents/features/documents/data/conversion/fonts/substitute_fonts.dart';

void main() {
  test('Word families map to their metric-compatible stand-ins', () {
    expect(substituteFor('Times New Roman'), SubstituteFamily.serif);
    expect(substituteFor('ARIAL'), SubstituteFamily.sans);
    expect(substituteFor('Courier New'), SubstituteFamily.mono);
    expect(substituteFor('Calibri Light'), SubstituteFamily.carlito);
  });

  test('unknown and missing families fall back to sans', () {
    expect(substituteFor('Aptos'), SubstituteFamily.sans);
    expect(substituteFor(null), SubstituteFamily.sans);
  });

  test('bundled assets provide every face', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final fonts = await const AssetFontLibrary().load();
    for (final family in SubstituteFamily.values) {
      for (final variant in FontVariant.values) {
        expect(
          fonts.face(family, variant),
          isNotEmpty,
          reason: '$family $variant',
        );
      }
    }
  });
}
