import 'package:flutter/widgets.dart';

import 'document_card.dart';

class DocumentListSkeleton extends StatelessWidget {
  const DocumentListSkeleton({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(count, (_) => const DocumentCardSkeleton()),
  );
}
