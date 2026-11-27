import 'package:flutter/widgets.dart';

import '../controls/icon_button.dart';
import '../data_display/text.dart';
import '../layout/divider.dart';
import '../tokens/app_spacing.dart';
import '../theme/app_tokens.dart';
import '../theme/graphics_mode.dart';
import '../tokens/app_icons.dart';
import 'barrier.dart';
import 'edge.dart';
import 'sheet_surface.dart';

export 'edge.dart';

class AppSidePanelController {
  const AppSidePanelController._(this._close);

  final Future<void> Function() _close;

  Future<void> close() => _close();
}

abstract final class AppSidePanel {
  static AppSidePanelController show({
    required BuildContext context,
    required Widget Function(
      BuildContext context,
      AppSidePanelController controller,
    )
    builder,
    AppEdge side = AppEdge.right,
    double panelFraction = 0.8,
    bool barrierDismissible = true,
    AppBarrierVariant? barrierVariant,
    String? dismissLabel,
  }) {
    final navigator = Navigator.of(context);
    late final _SidePanelRoute route;

    Future<void> close() async {
      if (!route.isActive) return;
      if (route.isCurrent) {
        navigator.pop();
      } else {
        navigator.removeRoute(route);
      }
      await route.completed;
    }

    final controller = AppSidePanelController._(close);
    route = _SidePanelRoute(
      side: side,
      panelFraction: panelFraction,
      tokens: context.tokens,
      barrier: AppBarrier.resolve(context, barrierVariant),
      dismissible: barrierDismissible,
      dismissLabel: dismissLabel,
      builder: (context) => builder(context, controller),
    );
    navigator.push(route);
    return controller;
  }
}

class _SidePanelRoute extends PopupRoute<void> {
  _SidePanelRoute({
    required this.side,
    required this.panelFraction,
    required this.tokens,
    required this.barrier,
    required this.dismissible,
    required this.dismissLabel,
    required this.builder,
  });

  final AppEdge side;
  final double panelFraction;
  final AppTokens tokens;
  final AppBarrierVariant barrier;
  final bool dismissible;
  final String? dismissLabel;
  final WidgetBuilder builder;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => dismissLabel;

  @override
  Duration get transitionDuration => tokens.motion.sheet;

  @override
  Duration get reverseTransitionDuration => tokens.motion.quick;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => AppThemeScope(
    tokens: tokens,
    child: Align(
      alignment: side.alignment,
      child: FractionallySizedBox(
        widthFactor: side.vertical ? 1 : panelFraction,
        heightFactor: side.vertical ? panelFraction : 1,
        child: SheetSurface(
          side: side,
          child: Builder(builder: builder),
        ),
      ),
    ),
  );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => Stack(
    fit: StackFit.expand,
    children: [
      AnimatedBuilder(
        animation: animation,
        builder: (context, _) => AppBarrierLayer(
          variant: barrier,
          animation: animation.value,
          semanticsLabel: dismissLabel,
          onTap: dismissible ? () => Navigator.of(context).maybePop() : null,
        ),
      ),
      SlideTransition(
        position: Tween(begin: side.hiddenOffset, end: Offset.zero).animate(
          CurvedAnimation(
            parent: animation,
            curve: AppMotion.curve,
            reverseCurve: Curves.easeIn,
          ),
        ),
        child: child,
      ),
    ],
  );
}

/// A side panel's title row, with an optional close button. Follows it with
/// an [AppDivider] — pair with [AppSidePanelContent] and, optionally,
/// [AppSidePanelFooter] inside the [AppSidePanel.show] `builder`'s `Column`.
class AppSidePanelHeader extends StatelessWidget {
  const AppSidePanelHeader({
    required this.title,
    this.onClose,
    this.closeLabel,
    super.key,
  });

  final String title;
  final VoidCallback? onClose;
  final String? closeLabel;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(child: AppText(title, variant: AppTextVariant.title)),
            if (onClose != null)
              AppIconButton(
                icon: AppIcons.x,
                onPressed: onClose,
                semanticsLabel: closeLabel,
              ),
          ],
        ),
      ),
      const AppDivider(),
    ],
  );
}

/// The side panel's scrollable body. Takes the remaining space between
/// [AppSidePanelHeader] and [AppSidePanelFooter] — must be a direct child of
/// the `builder`'s `Column`, since it uses [Expanded] internally.
class AppSidePanelContent extends StatelessWidget {
  const AppSidePanelContent({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Expanded(
    child: SingleChildScrollView(padding: padding, child: child),
  );
}

/// A row of actions pinned to the bottom of the panel, preceded by an
/// [AppDivider].
class AppSidePanelFooter extends StatelessWidget {
  const AppSidePanelFooter({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const AppDivider(),
      Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: AppSpacing.sm,
          children: children,
        ),
      ),
    ],
  );
}
