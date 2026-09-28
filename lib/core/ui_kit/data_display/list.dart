import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../controls/icon_button.dart';

/// A single row of data displayed in an [AppList].
///
/// Plain data, not a widget: [AppList] builds Forui's [FTile] from it
/// directly, since [FTileGroup] requires its children to be actual
/// [FTileMixin] instances (an intermediate wrapper widget wouldn't satisfy
/// that, and would break the group's divider/style inheritance).
class AppListItem {
  const AppListItem({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onTrailingTap,
  });

  final String title;
  final String? subtitle;
  final IconData? leading;
  final IconData? trailing;
  final VoidCallback? onTap;

  /// Makes [trailing] its own tappable action (e.g. delete) instead of a
  /// decorative icon riding along with [onTap].
  final VoidCallback? onTrailingTap;
}

/// A grouped, divided list of rows. Wraps Forui's [FTileGroup]/[FTile].
class AppList extends StatelessWidget {
  const AppList({required this.items, super.key});

  final List<AppListItem> items;

  @override
  Widget build(BuildContext context) => FTileGroup(
    children: [
      for (final item in items)
        FTile(
          title: Text(item.title),
          subtitle: item.subtitle == null ? null : Text(item.subtitle!),
          prefix: item.leading == null ? null : Icon(item.leading),
          suffix: item.trailing == null
              ? null
              : item.onTrailingTap == null
              ? Icon(item.trailing)
              : AppIconButton(
                  icon: item.trailing!,
                  onPressed: item.onTrailingTap,
                ),
          onPress: item.onTap,
        ),
    ],
  );
}
