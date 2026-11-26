import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/documents_providers.dart';
import 'document_selection_header.dart';

class DocumentSelectionAwareHeader extends ConsumerWidget {
  const DocumentSelectionAwareHeader({required this.normal, super.key});

  final Widget normal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selecting = ref.watch(documentSelectionProvider).isNotEmpty;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: selecting
          ? const DocumentSelectionHeader(key: ValueKey('selection'))
          : KeyedSubtree(key: const ValueKey('normal'), child: normal),
    );
  }
}
