import 'package:docx_creator/docx_creator.dart';

import '../fonts/substitute_fonts.dart';

/// Points every text run at a registered substitute face.
///
/// The exporter matches registered fonts by family name only, ignoring bold
/// and italic, so each face is registered under its own name and runs are
/// renamed to the face they need. Fonts embedded in the document win.
DocxBuiltDocument substituteFonts(
  DocxBuiltDocument document,
  SubstituteFonts fonts,
  PdfExporter exporter,
) {
  if (fonts.isEmpty) return document;
  final embedded = {for (final f in document.fonts) f.familyName.toLowerCase()};
  final registered = <String>{};
  final theme = document.theme?.fonts;
  final fallback = _resolve(
    document.theme?.defaultRunStyle?.fontFamily,
    document.theme?.defaultRunStyle?.fonts,
    theme,
  );

  DocxText text(DocxText run) {
    final family = _resolve(run.fontFamily, run.fonts, theme) ?? fallback;
    if (family != null && embedded.contains(family.toLowerCase())) return run;

    final substitute = substituteFor(family);
    final variant = FontVariant.of(
      bold: run.fontWeight == DocxFontWeight.bold,
      italic: run.fontStyle == DocxFontStyle.italic,
    );
    final bytes = fonts.face(substitute, variant);
    if (bytes == null) return run;
    final name = 'substitute-${substitute.name}-${variant.name}';
    if (registered.add(name)) exporter.registerFont(name, bytes);
    return run.copyWith(fontFamily: name);
  }

  List<DocxInline> inlines(List<DocxInline> nodes) => [
    for (final node in nodes) node is DocxText ? text(node) : node,
  ];

  late final List<DocxBlock> Function(List<DocxBlock>) blocks;

  DocxNode node(DocxNode node) => switch (node) {
    DocxParagraph p => p.copyWith(children: inlines(p.children)),
    DocxList l => l.copyWith(
      items: [
        for (final item in l.items)
          item.copyWith(children: inlines(item.children)),
      ],
    ),
    DocxTable t => t.copyWith(
      rows: [
        for (final row in t.rows)
          row.copyWith(
            cells: [
              for (final cell in row.cells)
                cell.copyWith(children: blocks(cell.children)),
            ],
          ),
      ],
    ),
    _ => node,
  };

  blocks = (nodes) => [for (final n in nodes) node(n) as DocxBlock];

  final section = document.section;
  return DocxBuiltDocument(
    elements: [for (final e in document.elements) node(e)],
    section: section?.copyWith(
      header: section.header?.copyWith(
        children: blocks(section.header!.children),
      ),
      footer: section.footer?.copyWith(
        children: blocks(section.footer!.children),
      ),
    ),
    footnotes: [
      for (final n in document.footnotes ?? const <DocxFootnote>[])
        n.copyWith(content: blocks(n.content)),
    ],
    endnotes: [
      for (final n in document.endnotes ?? const <DocxEndnote>[])
        n.copyWith(content: blocks(n.content)),
    ],
    stylesXml: document.stylesXml,
    numberingXml: document.numberingXml,
    settingsXml: document.settingsXml,
    fontTableXml: document.fontTableXml,
    fontTableRelsXml: document.fontTableRelsXml,
    themeXml: document.themeXml,
    contentTypesXml: document.contentTypesXml,
    rootRelsXml: document.rootRelsXml,
    headerBgXml: document.headerBgXml,
    headerBgRelsXml: document.headerBgRelsXml,
    footnotesXml: document.footnotesXml,
    endnotesXml: document.endnotesXml,
    numberingRelsXml: document.numberingRelsXml,
    numberingImages: document.numberingImages,
    fonts: document.fonts,
    theme: document.theme,
  );
}

String? _resolve(String? family, DocxFont? fonts, DocxThemeFonts? theme) {
  if (family != null) return family;
  if (fonts?.ascii case final ascii?) return ascii;
  return switch (fonts?.asciiTheme) {
    null => null,
    final ref when ref.startsWith('major') => theme?.majorLatin,
    _ => theme?.minorLatin,
  };
}
