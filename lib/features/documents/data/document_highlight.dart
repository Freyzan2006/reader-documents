import 'package:flutter/painting.dart';

import 'document_rect.dart';

enum DocumentHighlightColor { yellow, green, pink }

extension DocumentHighlightColorValue on DocumentHighlightColor {
  Color get value => switch (this) {
    DocumentHighlightColor.yellow => const Color(0xFFFFEB3B),
    DocumentHighlightColor.green => const Color(0xFF69F0AE),
    DocumentHighlightColor.pink => const Color(0xFFFF80AB),
  };
}

class DocumentHighlightDraft {
  const DocumentHighlightDraft({
    required this.pageNumber,
    required this.startIndex,
    required this.endIndex,
    required this.text,
    required this.rects,
  });

  final int pageNumber;
  final int startIndex;
  final int endIndex;
  final String text;
  final List<DocumentRect> rects;
}

class DocumentHighlight {
  const DocumentHighlight({
    required this.id,
    required this.pageNumber,
    required this.startIndex,
    required this.endIndex,
    required this.rects,
    required this.color,
    required this.text,
    required this.createdAt,
  });

  factory DocumentHighlight.fromDraft({
    required String id,
    required DocumentHighlightDraft draft,
    required DocumentHighlightColor color,
  }) => DocumentHighlight(
    id: id,
    pageNumber: draft.pageNumber,
    startIndex: draft.startIndex,
    endIndex: draft.endIndex,
    rects: draft.rects,
    color: color,
    text: draft.text,
    createdAt: DateTime.now(),
  );

  factory DocumentHighlight.fromJson(Map<String, dynamic> json) =>
      DocumentHighlight(
        id: json['id'] as String,
        pageNumber: json['pageNumber'] as int,
        startIndex: json['startIndex'] as int,
        endIndex: json['endIndex'] as int,
        rects: (json['rects'] as List<dynamic>)
            .map((r) => DocumentRect.fromJson((r as List<dynamic>).cast<num>()))
            .toList(),
        color: DocumentHighlightColor.values.byName(json['color'] as String),
        text: json['text'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String id;
  final int pageNumber;
  final int startIndex;
  final int endIndex;
  final List<DocumentRect> rects;
  final DocumentHighlightColor color;
  final String text;
  final DateTime createdAt;

  bool overlapsRange(int pageNumber, int start, int end) =>
      this.pageNumber == pageNumber && startIndex < end && start < endIndex;

  Map<String, dynamic> toJson() => {
    'id': id,
    'pageNumber': pageNumber,
    'startIndex': startIndex,
    'endIndex': endIndex,
    'rects': rects.map((r) => r.toJson()).toList(),
    'color': color.name,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
  };

  static List<DocumentRect> lineRects(
    List<DocumentRect> charRects,
    int start,
    int end,
  ) {
    if (start >= end || end > charRects.length) return const [];

    final lines = <DocumentRect>[];
    var lineStart = start;
    for (var i = start + 1; i <= end; i++) {
      final atLineBreak =
          i == end || _onDifferentLine(charRects[i - 1], charRects[i]);
      if (atLineBreak) {
        lines.add(
          DocumentRect.boundingRect(charRects, start: lineStart, end: i),
        );
        lineStart = i;
      }
    }
    return lines;
  }

  static bool _onDifferentLine(DocumentRect a, DocumentRect b) {
    final aCenter = (a.top + a.bottom) / 2;
    final bCenter = (b.top + b.bottom) / 2;
    final threshold = (a.height < b.height ? a.height : b.height) / 2;
    return (aCenter - bCenter).abs() > threshold;
  }
}
