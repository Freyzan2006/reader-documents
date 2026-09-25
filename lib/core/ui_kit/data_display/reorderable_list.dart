import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../tokens/app_spacing.dart';

class AppReorderableList<T> extends StatelessWidget {
  const AppReorderableList({
    required this.items,
    required this.itemKey,
    required this.itemBuilder,
    required this.onReorder,
    super.key,
  });

  final List<T> items;
  final Key Function(T item) itemKey;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    shrinkWrap: true,
    slivers: [
      SliverReorderableList(
        itemCount: items.length,
        onReorderItem: onReorder,
        itemBuilder: (context, index) {
          final item = items[index];
          return Row(
            key: itemKey(item),
            children: [
              Expanded(child: itemBuilder(context, item, index)),
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: Icon(FLucideIcons.gripVertical),
                ),
              ),
            ],
          );
        },
      ),
    ],
  );
}
