import 'dart:typed_data';

/// Free fonts that stand in for the proprietary families documents ask for.
/// Each covers Latin and Cyrillic, and the first three are metric-compatible
/// with Times New Roman, Arial and Courier New, Carlito with Calibri.
enum SubstituteFamily { serif, sans, mono, carlito }

enum FontVariant {
  regular,
  bold,
  italic,
  boldItalic;

  static FontVariant of({required bool bold, required bool italic}) =>
      switch ((bold, italic)) {
        (false, false) => FontVariant.regular,
        (true, false) => FontVariant.bold,
        (false, true) => FontVariant.italic,
        (true, true) => FontVariant.boldItalic,
      };
}

/// Font bytes per family and variant. Plain data, so it can be sent to the
/// isolate that runs the conversion.
final class SubstituteFonts {
  const SubstituteFonts(this._faces);

  const SubstituteFonts.none() : _faces = const {};

  final Map<(SubstituteFamily, FontVariant), Uint8List> _faces;

  Uint8List? face(SubstituteFamily family, FontVariant variant) =>
      _faces[(family, variant)] ?? _faces[(family, FontVariant.regular)];

  bool get isEmpty => _faces.isEmpty;
}

abstract interface class FontLibrary {
  Future<SubstituteFonts> load();
}

/// Families not listed here fall back to [SubstituteFamily.sans], so a
/// document never mixes the PDF base fonts with the Unicode fallback in one
/// line.
SubstituteFamily substituteFor(String? family) {
  final key = family?.split(',').first.trim().toLowerCase() ?? '';
  return _families[key] ?? SubstituteFamily.sans;
}

const _families = {
  'times new roman': SubstituteFamily.serif,
  'times': SubstituteFamily.serif,
  'liberation serif': SubstituteFamily.serif,
  'tinos': SubstituteFamily.serif,
  'cambria': SubstituteFamily.serif,
  'georgia': SubstituteFamily.serif,
  'garamond': SubstituteFamily.serif,
  'book antiqua': SubstituteFamily.serif,
  'palatino linotype': SubstituteFamily.serif,
  'pt serif': SubstituteFamily.serif,
  'serif': SubstituteFamily.serif,
  'courier new': SubstituteFamily.mono,
  'courier': SubstituteFamily.mono,
  'consolas': SubstituteFamily.mono,
  'lucida console': SubstituteFamily.mono,
  'liberation mono': SubstituteFamily.mono,
  'cousine': SubstituteFamily.mono,
  'monospace': SubstituteFamily.mono,
  'calibri': SubstituteFamily.carlito,
  'calibri light': SubstituteFamily.carlito,
  'carlito': SubstituteFamily.carlito,
};
