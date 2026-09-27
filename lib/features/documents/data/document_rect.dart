class DocumentRect {
  const DocumentRect(this.left, this.top, this.right, this.bottom)
    : assert(left <= right),
      assert(top >= bottom);

  final double left;
  final double top;
  final double right;
  final double bottom;

  double get height => top - bottom;

  static DocumentRect fromJson(List<num> values) => DocumentRect(
    values[0].toDouble(),
    values[1].toDouble(),
    values[2].toDouble(),
    values[3].toDouble(),
  );

  List<double> toJson() => [left, top, right, bottom];

  static DocumentRect boundingRect(
    List<DocumentRect> rects, {
    int? start,
    int? end,
  }) {
    final from = start ?? 0;
    final to = end ?? rects.length;
    var left = double.infinity;
    var top = double.negativeInfinity;
    var right = double.negativeInfinity;
    var bottom = double.infinity;
    for (final rect in rects.skip(from).take(to - from)) {
      if (rect.left < left) left = rect.left;
      if (rect.top > top) top = rect.top;
      if (rect.right > right) right = rect.right;
      if (rect.bottom < bottom) bottom = rect.bottom;
    }
    return DocumentRect(left, top, right, bottom);
  }
}
