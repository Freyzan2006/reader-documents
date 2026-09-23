import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../controls/button.dart';
import '../data_display/text.dart';
import '../layout/divider.dart';
import '../tokens/app_spacing.dart';
import 'sheet_surface.dart';

/// Controls a panel opened by [AppSidePanel.show].
class AppSidePanelController {
  const AppSidePanelController._(this._close);

  final Future<void> Function() _close;

  /// Animates the panel closed, then removes it. Safe to call more than
  /// once (later calls are no-ops).
  Future<void> close() => _close();
}

/// A panel docked to one edge of the screen, dimming and blocking
/// interaction with the rest of the app while shown — the same "modal"
/// behavior as [AppSheet], just anchored to a side instead of the bottom.
///
/// Forui's own `showFPersistentSheet` was tried here first and dropped: it's
/// explicitly the *non*-modal sheet (no barrier at all, by design — see its
/// docs), and its single-child sliding mechanism (`Sheet`/`ShiftedSheet`)
/// has no room to add one without the barrier incorrectly sliding in lock-step
/// with the panel instead of staying put and simply fading. So this is a
/// small bespoke overlay instead: an [Overlay] entry with a fading barrier
/// (tap to dismiss) behind a [SlideTransition]-driven panel, sized to
/// [panelFraction] of the screen.
///
/// Doesn't require an `FScaffold` — any `BuildContext` with an [Overlay]
/// ancestor works (so, anywhere under `MaterialApp`).
abstract final class AppSidePanel {
  static AppSidePanelController show({
    required BuildContext context,
    required Widget Function(
      BuildContext context,
      AppSidePanelController controller,
    )
    builder,
    FLayout side = FLayout.rtl,
    double panelFraction = 0.8,
    bool barrierDismissible = true,
  }) {
    final overlay = Overlay.of(context);
    final key = GlobalKey<_SidePanelOverlayState>();
    late final OverlayEntry entry;
    var closed = false;

    Future<void> close() async {
      if (closed) return;
      closed = true;
      await key.currentState?.animateOut();
      entry.remove();
    }

    final controller = AppSidePanelController._(close);

    entry = OverlayEntry(
      builder: (context) => _SidePanelOverlay(
        key: key,
        side: side,
        panelFraction: panelFraction,
        barrierDismissible: barrierDismissible,
        onBarrierTap: close,
        builder: (context) => builder(context, controller),
      ),
    );

    overlay.insert(entry);
    return controller;
  }
}

class _SidePanelOverlay extends StatefulWidget {
  const _SidePanelOverlay({
    required this.side,
    required this.panelFraction,
    required this.barrierDismissible,
    required this.onBarrierTap,
    required this.builder,
    super.key,
  });

  final FLayout side;
  final double panelFraction;
  final bool barrierDismissible;
  final VoidCallback onBarrierTap;
  final WidgetBuilder builder;

  @override
  State<_SidePanelOverlay> createState() => _SidePanelOverlayState();
}

class _SidePanelOverlayState extends State<_SidePanelOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  )..forward();
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  Future<void> animateOut() => _controller.reverse();

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  Offset get _hiddenOffset => switch (widget.side) {
    FLayout.rtl => const Offset(1, 0),
    FLayout.ltr => const Offset(-1, 0),
    FLayout.ttb => const Offset(0, -1),
    FLayout.btt => const Offset(0, 1),
  };

  Alignment get _alignment => switch (widget.side) {
    FLayout.rtl => Alignment.centerRight,
    FLayout.ltr => Alignment.centerLeft,
    FLayout.ttb => Alignment.topCenter,
    FLayout.btt => Alignment.bottomCenter,
  };

  @override
  Widget build(BuildContext context) {
    final barrierColor = context.theme.colors.barrier;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              ignoring: _controller.value == 0,
              child: GestureDetector(
                onTap: widget.barrierDismissible ? widget.onBarrierTap : null,
                child: ColoredBox(
                  color: barrierColor.withValues(
                    alpha: barrierColor.a * _controller.value,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: _alignment,
            child: FractionallySizedBox(
              widthFactor: widget.side.vertical ? 1 : widget.panelFraction,
              heightFactor: widget.side.vertical ? widget.panelFraction : 1,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: _hiddenOffset,
                  end: Offset.zero,
                ).animate(_curve),
                child: SheetSurface(
                  side: widget.side,
                  child: widget.builder(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A side panel's title row, with an optional close button. Follows it with
/// an [AppDivider] — pair with [AppSidePanelContent] and, optionally,
/// [AppSidePanelFooter] inside the [AppSidePanel.show] `builder`'s `Column`.
class AppSidePanelHeader extends StatelessWidget {
  const AppSidePanelHeader({required this.title, this.onClose, super.key});

  final String title;
  final VoidCallback? onClose;

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
              AppButton(
                variant: AppButtonVariant.ghost,
                onPressed: onClose,
                child: const Icon(FLucideIcons.x),
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
