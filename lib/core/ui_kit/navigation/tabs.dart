import 'package:flutter/widgets.dart';

import '../tokens/app_spacing.dart';
import 'segmented.dart';

class AppTab {
  const AppTab({required this.label, required this.child});

  final String label;
  final Widget child;
}

class AppTabs extends StatefulWidget {
  const AppTabs({
    required this.tabs,
    this.initialIndex = 0,
    this.onChanged,
    this.expands = false,
    this.scrollable = false,
    super.key,
  });

  final List<AppTab> tabs;
  final int initialIndex;
  final ValueChanged<int>? onChanged;
  final bool expands;
  final bool scrollable;

  @override
  State<AppTabs> createState() => _AppTabsState();
}

class _AppTabsState extends State<AppTabs> {
  late int _index = widget.initialIndex.clamp(0, widget.tabs.length - 1);

  void _select(int index) {
    if (index == _index) return;
    setState(() => _index = index);
    widget.onChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final bar = AppSegmented<int>(
      expand: !widget.scrollable,
      value: _index,
      onChanged: _select,
      segments: [
        for (final (index, tab) in widget.tabs.indexed)
          AppSegment(value: index, label: tab.label),
      ],
    );
    final body = IndexedStack(
      index: _index,
      children: [for (final tab in widget.tabs) tab.child],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: widget.expands ? MainAxisSize.max : MainAxisSize.min,
      spacing: AppSpacing.md,
      children: [
        if (widget.scrollable)
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: bar)
        else
          bar,
        if (widget.expands) Expanded(child: body) else body,
      ],
    );
  }
}
