class DocumentBookmark {
  const DocumentBookmark({
    required this.id,
    required this.pageNumber,
    required this.note,
    required this.createdAt,
  });

  factory DocumentBookmark.create({
    required String id,
    required int pageNumber,
    required String note,
  }) => DocumentBookmark(
    id: id,
    pageNumber: pageNumber,
    note: note,
    createdAt: DateTime.now(),
  );

  factory DocumentBookmark.fromJson(Map<String, dynamic> json) =>
      DocumentBookmark(
        id: json['id'] as String,
        pageNumber: json['pageNumber'] as int,
        note: json['note'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String id;
  final int pageNumber;
  final String note;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'pageNumber': pageNumber,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
  };
}
