enum DocumentType {
  pdf,
  docx,
  djvu,
  other;

  String get label => switch (this) {
    DocumentType.pdf => 'PDF',
    DocumentType.docx => 'DOCX',
    DocumentType.djvu => 'DjVu',
    DocumentType.other => 'Other',
  };
}

DocumentType documentTypeFromExtension(String extension) =>
    switch (extension.toLowerCase()) {
      'pdf' => DocumentType.pdf,
      'docx' => DocumentType.docx,
      'djvu' => DocumentType.djvu,
      _ => DocumentType.other,
    };

class DocumentFile {
  const DocumentFile({
    required this.path,
    required this.name,
    required this.type,
    required this.sizeBytes,
    required this.modifiedAt,
  });

  final String path;
  final String name;
  final DocumentType type;
  final int sizeBytes;
  final DateTime modifiedAt;

  String get formattedSize => formatBytes(sizeBytes);

  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
