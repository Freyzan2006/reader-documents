import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// A single tab: its label and the content it shows when selected.
class AppTab {
  const AppTab({required this.label, required this.child});

  final String label;
  final Widget child;
}

/// A tabbed layout. Wraps Forui's [FTabs]/[FTabEntry].
class AppTabs extends StatelessWidget {
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

  /// Whether the selected tab's content should expand to fill the
  /// remaining space. Required for a tab whose content is itself a
  /// scrollable (e.g. `ListView`) — without it, that content is laid out
  /// with unbounded height and crashes.
  final bool expands;

  /// When true, each tab is only as wide as its label needs and the tab
  /// bar itself scrolls horizontally — instead of stretching every label
  /// to an equal share of the width, which squeezes/wraps longer labels.
  final bool scrollable;

  @override
  Widget build(BuildContext context) => FTabs(
    control: FTabControl.managed(initial: initialIndex, onChange: onChanged),
    expands: expands,
    scrollable: scrollable,
    children: [
      for (final tab in tabs)
        FTabEntry(label: Text(tab.label), child: tab.child),
    ],
  );
}
