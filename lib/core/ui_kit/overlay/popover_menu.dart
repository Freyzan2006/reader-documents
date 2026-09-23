import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import 'command_palette.dart' show AppCommandItem;

class AppPopoverMenu extends StatelessWidget {
  const AppPopoverMenu({required this.items, required this.child, super.key});

  final List<AppCommandItem> items;
  final Widget child;

  @override
  Widget build(BuildContext context) => FPopoverMenu.tiles(
    menuBuilder: (context, controller, _) => [
      FTileGroup(
        children: [
          for (final item in items)
            FTile(
              title: Text(item.label),
              prefix: item.icon == null ? null : Icon(item.icon),
              onPress: () {
                controller.hide();
                item.onSelect();
              },
            ),
        ],
      ),
    ],
    builder: (context, controller, child) =>
        FTappable(onPress: controller.toggle, child: child!),
    child: child,
  );
}
