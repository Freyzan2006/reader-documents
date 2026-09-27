class DocumentOutlineNode {
  const DocumentOutlineNode({
    required this.title,
    required this.pageNumber,
    required this.children,
  });

  final String title;
  final int? pageNumber;
  final List<DocumentOutlineNode> children;
}
