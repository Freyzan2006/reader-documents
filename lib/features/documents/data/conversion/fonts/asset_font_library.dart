import 'package:flutter/services.dart';

import 'substitute_fonts.dart';

final class AssetFontLibrary implements FontLibrary {
  const AssetFontLibrary({this.bundle});

  final AssetBundle? bundle;

  static const _directory = 'assets/docx_fonts';

  static const _files = {
    SubstituteFamily.serif: 'LiberationSerif',
    SubstituteFamily.sans: 'LiberationSans',
    SubstituteFamily.mono: 'LiberationMono',
    SubstituteFamily.carlito: 'Carlito',
  };

  static const _suffixes = {
    FontVariant.regular: 'Regular',
    FontVariant.bold: 'Bold',
    FontVariant.italic: 'Italic',
    FontVariant.boldItalic: 'BoldItalic',
  };

  @override
  Future<SubstituteFonts> load() async {
    final source = bundle ?? rootBundle;
    Future<MapEntry<(SubstituteFamily, FontVariant), Uint8List>> face(
      SubstituteFamily family,
      FontVariant variant,
    ) async {
      final data = await source.load(
        '$_directory/${_files[family]}-${_suffixes[variant]}.ttf',
      );
      return MapEntry((family, variant), data.buffer.asUint8List());
    }

    final faces =
        <Future<MapEntry<(SubstituteFamily, FontVariant), Uint8List>>>[];
    for (final family in SubstituteFamily.values) {
      for (final variant in FontVariant.values) {
        faces.add(face(family, variant));
      }
    }
    return SubstituteFonts(Map.fromEntries(await Future.wait(faces)));
  }
}
