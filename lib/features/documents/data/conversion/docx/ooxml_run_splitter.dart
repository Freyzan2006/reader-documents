import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

/// Rewrites a DOCX so that every `w:r` carries a single content element.
///
/// `docx_creator` maps one run to one inline: text that shares a run with a
/// break, a tab or a second `w:t` is dropped. Word and Google Docs write such
/// runs routinely (e.g. a list item ending in a soft line break).
Uint8List splitMixedRuns(Uint8List docx) {
  final archive = ZipDecoder().decodeBytes(docx);
  final output = Archive();
  var changed = false;
  for (final file in archive.files) {
    if (file.isFile && _storyPart.hasMatch(file.name)) {
      final xml = utf8.decode(file.content);
      final split = _splitRuns(xml);
      if (split != null) {
        changed = true;
        output.addFile(ArchiveFile.bytes(file.name, utf8.encode(split)));
        continue;
      }
    }
    output.addFile(file);
  }
  if (!changed) return docx;
  return Uint8List.fromList(ZipEncoder().encode(output));
}

final _storyPart = RegExp(
  r'^word/(document|header\d*|footer\d*|footnotes|endnotes)\.xml$',
);

const _ignored = {'rPr', 'lastRenderedPageBreak'};

String? _splitRuns(String source) {
  final document = XmlDocument.parse(source);
  final runs = document.descendants
      .whereType<XmlElement>()
      .where((e) => e.name.local == 'r' && e.name.prefix == 'w')
      .toList();
  var changed = false;
  for (final run in runs) {
    final properties = run.getElement('w:rPr');
    final content = [
      for (final child in run.childElements)
        if (!_ignored.contains(child.name.local)) _normalize(child),
    ];
    if (content.length < 2) continue;

    final pieces = [
      for (final element in content)
        XmlElement(
          XmlName.qualified(run.name.qualified),
          run.attributes.map((a) => a.copy()),
          [?properties?.copy(), element.copy()],
        ),
    ];
    run.replace(XmlDocumentFragment(pieces));
    changed = true;
  }
  return changed ? document.toXmlString() : null;
}

/// Elements the parser would otherwise turn into unrendered raw XML.
XmlElement _normalize(XmlElement element) => switch (element.name.local) {
  'cr' => XmlElement(XmlName.qualified('w:br')),
  'noBreakHyphen' => XmlElement(XmlName.qualified('w:t'), [], [XmlText('‑')]),
  _ => element,
};
