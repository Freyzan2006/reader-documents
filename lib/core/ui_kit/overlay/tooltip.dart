import 'dart:async';

import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class AppTooltip extends StatefulWidget {
  const AppTooltip({this.message, this.tip, required this.child, super.key})
    : assert(
        message != null || tip != null,
        'Either message or tip must be provided.',
      );

  static const _visibleFor = Duration(seconds: 3);

  final String? message;
  final Widget? tip;
  final Widget child;

  @override
  State<AppTooltip> createState() => _AppTooltipState();
}

class _AppTooltipState extends State<AppTooltip> {
  static const _gap = 8.0;
  static const _maxWidth = 280.0;

  final _portal = OverlayPortalController();
  final _link = LayerLink();
  Timer? _hideTimer;

  void _show({bool autoHide = true}) {
    _hideTimer?.cancel();
    if (!_portal.isShowing) _portal.show();
    if (autoHide) _hideTimer = Timer(AppTooltip._visibleFor, _hide);
  }

  void _hide() {
    _hideTimer?.cancel();
    if (_portal.isShowing && mounted) _portal.hide();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  Widget _bubble(BuildContext context) {
    final tokens = context.tokens;
    final palette = tokens.palette;
    return CompositedTransformFollower(
      link: _link,
      targetAnchor: Alignment.bottomCenter,
      followerAnchor: Alignment.topCenter,
      offset: const Offset(0, _gap),
      child: Align(
        alignment: Alignment.topCenter,
        child: TapRegion(
          onTapOutside: (_) => _hide(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: palette.sheet,
                borderRadius: AppRadii.sm,
                border: Border.all(color: palette.rule),
                boxShadow: tokens.elevation.pop,
              ),
              child: DefaultTextStyle.merge(
                style: AppTextStyles.caption.copyWith(color: palette.ink),
                child: widget.tip ?? Text(widget.message!),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Semantics(
    tooltip: widget.message,
    child: CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: _bubble,
        child: MouseRegion(
          onEnter: (_) => _show(autoHide: false),
          onExit: (_) => _hide(),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            excludeFromSemantics: true,
            onLongPress: _show,
            child: widget.child,
          ),
        ),
      ),
    ),
  );
}
