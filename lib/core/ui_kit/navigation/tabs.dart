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
    super.key,
  });

  final List<AppTab> tabs;
  final int initialIndex;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) => FTabs(
    control: FTabControl.managed(initial: initialIndex, onChange: onChanged),
    children: [
      for (final tab in tabs)
        FTabEntry(label: Text(tab.label), child: tab.child),
    ],
  );
}
