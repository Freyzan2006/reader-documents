import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../data_display/list.dart';
import '../primitives/tappable.dart';
import '../theme/app_tokens.dart';
import '../tokens/app_radius.dart';
import 'command_palette.dart' show AppCommandItem;

class AppPopoverMenu extends StatefulWidget {
  const AppPopoverMenu({
    required this.items,
    required this.child,
    this.semanticsLabel,
    super.key,
  });

  final List<AppCommandItem> items;
  final Widget child;
  final String? semanticsLabel;

  @override
  State<AppPopoverMenu> createState() => _AppPopoverMenuState();
}

class _AppPopoverMenuState extends State<AppPopoverMenu> {
  static const _gap = 6.0;
  static const _width = 240.0;

  final _portal = OverlayPortalController();
  final _link = LayerLink();
  final _region = Object();

  void _toggle() => _portal.isShowing ? _portal.hide() : _portal.show();

  void _select(AppCommandItem item) {
    _portal.hide();
    item.onSelect();
  }

  Widget _menu(BuildContext context) {
    final tokens = context.tokens;
    final palette = tokens.palette;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): _portal.hide,
      },
      child: CompositedTransformFollower(
        link: _link,
        targetAnchor: Alignment.bottomRight,
        followerAnchor: Alignment.topRight,
        offset: const Offset(0, _gap),
        child: Align(
          alignment: Alignment.topRight,
          child: TapRegion(
            groupId: _region,
            onTapOutside: (_) => _portal.hide(),
            child: Container(
              width: _width,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: palette.sheet,
                borderRadius: AppRadii.md,
                border: Border.all(color: palette.rule),
                boxShadow: tokens.elevation.pop,
              ),
              child: FocusScope(
                autofocus: true,
                child: AppListGroup(
                  framed: false,
                  children: [
                    for (final item in widget.items)
                      AppListRow(
                        title: item.label,
                        subtitle: item.subtitle,
                        leading: item.icon,
                        onTap: () => _select(item),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => CompositedTransformTarget(
    link: _link,
    child: OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _menu,
      child: TapRegion(
        groupId: _region,
        child: AppTappable(
          onPressed: _toggle,
          semanticsLabel: widget.semanticsLabel,
          child: widget.child,
        ),
      ),
    ),
  );
}
