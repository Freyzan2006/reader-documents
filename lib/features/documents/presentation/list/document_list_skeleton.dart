import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

import 'document_card.dart';

class DocumentListSkeleton extends StatelessWidget {
  const DocumentListSkeleton({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) => Column(
    spacing: AppSpacing.sm,
    children: List.generate(count, (_) => const DocumentCardSkeleton()),
  );
}
