import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class AppAccordionItem {
  const AppAccordionItem({required this.title, required this.child});

  final String title;
  final Widget child;
}

class AppAccordion extends StatelessWidget {
  const AppAccordion({required this.items, super.key});

  final List<AppAccordionItem> items;

  @override
  Widget build(BuildContext context) => FAccordion(
    children: [
      for (final item in items)
        FAccordionItem(title: Text(item.title), child: item.child),
    ],
  );
}
