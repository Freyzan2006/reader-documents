import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';

@immutable
final class AppTapState {
  const AppTapState({
    required this.pressed,
    required this.focused,
    required this.enabled,
  });

  final bool pressed;
  final bool focused;
  final bool enabled;
}

typedef AppTapBuilder = Widget Function(
  BuildContext context,
  AppTapState state,
);

class AppTappable extends StatefulWidget {
  const AppTappable({
    required Widget this.child,
    this.onPressed,
    this.onLongPress,
    this.selected = false,
    this.semanticsLabel,
    this.semanticsHint,
    this.pressedOpacity = 0.72,
    this.excludeChildSemantics = false,
    super.key,
  }) : builder = null;

  const AppTappable.builder({
    required AppTapBuilder this.builder,
    this.onPressed,
    this.onLongPress,
    this.selected = false,
    this.semanticsLabel,
    this.semanticsHint,
    this.excludeChildSemantics = false,
    super.key,
  }) : child = null,
       pressedOpacity = 1;

  final Widget? child;
  final AppTapBuilder? builder;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool selected;
  final String? semanticsLabel;
  final String? semanticsHint;
  final double pressedOpacity;
  final bool excludeChildSemantics;

  @override
  State<AppTappable> createState() => _AppTappableState();
}

class _AppTappableState extends State<AppTappable> {
  bool _pressed = false;
  bool _focused = false;

  bool get _enabled => widget.onPressed != null || widget.onLongPress != null;

  late final Map<Type, Action<Intent>> _actions = {
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) => _activate(),
    ),
  };

  void _activate() {
    final onPressed = widget.onPressed;
    if (onPressed == null) return;
    onPressed();
  }

  void _setPressed(bool value) {
    if (_pressed == value || !mounted) return;
    setState(() => _pressed = value);
  }

  @override
  void didUpdateWidget(AppTappable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_enabled) _pressed = false;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppTapState(
      pressed: _pressed,
      focused: _focused,
      enabled: _enabled,
    );
    final builder = widget.builder;
    final content = builder != null
        ? builder(context, state)
        : AnimatedOpacity(
            opacity: _pressed ? widget.pressedOpacity : 1,
            duration: context.tokens.motion.quick,
            curve: Curves.easeOut,
            child: widget.child,
          );

    return Semantics(
      button: _enabled,
      enabled: _enabled,
      selected: widget.selected,
      label: widget.semanticsLabel,
      hint: widget.semanticsHint,
      excludeSemantics: widget.excludeChildSemantics,
      onTap: widget.onPressed == null ? null : _activate,
      onLongPress: widget.onLongPress,
      child: FocusableActionDetector(
        enabled: _enabled,
        actions: _actions,
        mouseCursor: _enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTapDown: _enabled ? (_) => _setPressed(true) : null,
          onTapUp: _enabled ? (_) => _setPressed(false) : null,
          onTapCancel: _enabled ? () => _setPressed(false) : null,
          onTap: widget.onPressed == null ? null : _activate,
          onLongPress: widget.onLongPress == null
              ? null
              : () {
                  _setPressed(false);
                  HapticFeedback.mediumImpact();
                  widget.onLongPress!();
                },
          child: content,
        ),
      ),
    );
  }
}

class AppFocusRing extends StatelessWidget {
  const AppFocusRing({
    required this.visible,
    required this.borderRadius,
    required this.child,
    super.key,
  });

  final bool visible;
  final BorderRadius borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    position: DecorationPosition.foreground,
    decoration: visible
        ? BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(
              color: context.tokens.palette.focus,
              width: 2,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          )
        : const BoxDecoration(),
    child: child,
  );
}
