import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

class DocumentListEmptyState extends StatelessWidget {
  const DocumentListEmptyState({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) =>
      AppEmptyState(icon: AppIcons.fileText, message: message);
}
