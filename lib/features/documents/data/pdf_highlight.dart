import 'package:flutter/painting.dart';
import 'package:pdfrx/pdfrx.dart';

enum PdfHighlightColor { yellow, green, pink }

extension PdfHighlightColorValue on PdfHighlightColor {
  Color get value => switch (this) {
    PdfHighlightColor.yellow => const Color(0xFFFFEB3B),
    PdfHighlightColor.green => const Color(0xFF69F0AE),
    PdfHighlightColor.pink => const Color(0xFFFF80AB),
  };
}

class PdfHighlight {
  const PdfHighlight({
    required this.id,
    required this.pageNumber,
    required this.startIndex,
    required this.endIndex,
    required this.rects,
    required this.color,
    required this.text,
    required this.createdAt,
  });

  factory PdfHighlight.fromSelection({
    required String id,
    required PdfPageText pageText,
    required int startIndex,
    required int endIndex,
    required PdfHighlightColor color,
  }) => PdfHighlight(
    id: id,
    pageNumber: pageText.pageNumber,
    startIndex: startIndex,
    endIndex: endIndex,
    rects: _lineRects(pageText.charRects, startIndex, endIndex),
    color: color,
    text: pageText.fullText.substring(startIndex, endIndex),
    createdAt: DateTime.now(),
  );

  factory PdfHighlight.fromJson(Map<String, dynamic> json) => PdfHighlight(
    id: json['id'] as String,
    pageNumber: json['pageNumber'] as int,
    startIndex: json['startIndex'] as int,
    endIndex: json['endIndex'] as int,
    rects: (json['rects'] as List<dynamic>)
        .map((r) => _rectFromJson((r as List<dynamic>).cast<num>()))
        .toList(),
    color: PdfHighlightColor.values.byName(json['color'] as String),
    text: json['text'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  final String id;
  final int pageNumber;
  final int startIndex;
  final int endIndex;
  final List<PdfRect> rects;
  final PdfHighlightColor color;
  final String text;
  final DateTime createdAt;

  bool overlapsRange(int pageNumber, int start, int end) =>
      this.pageNumber == pageNumber && startIndex < end && start < endIndex;

  Map<String, dynamic> toJson() => {
    'id': id,
    'pageNumber': pageNumber,
    'startIndex': startIndex,
    'endIndex': endIndex,
    'rects': rects.map((r) => [r.left, r.top, r.right, r.bottom]).toList(),
    'color': color.name,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
  };

  static PdfRect _rectFromJson(List<num> values) => PdfRect(
    values[0].toDouble(),
    values[1].toDouble(),
    values[2].toDouble(),
    values[3].toDouble(),
  );

  /// Groups the selected characters into one rect per line, instead of a
  /// single box spanning the full height of a multi-line selection.
  static List<PdfRect> _lineRects(List<PdfRect> charRects, int start, int end) {
    if (start >= end || end > charRects.length) return const [];

    final lines = <PdfRect>[];
    var lineStart = start;
    for (var i = start + 1; i <= end; i++) {
      final atLineBreak =
          i == end || _onDifferentLine(charRects[i - 1], charRects[i]);
      if (atLineBreak) {
        lines.add(charRects.boundingRect(start: lineStart, end: i));
        lineStart = i;
      }
    }
    return lines;
  }

  static bool _onDifferentLine(PdfRect a, PdfRect b) {
    final aCenter = (a.top + a.bottom) / 2;
    final bCenter = (b.top + b.bottom) / 2;
    final threshold = (a.height < b.height ? a.height : b.height) / 2;
    return (aCenter - bCenter).abs() > threshold;
  }
}
