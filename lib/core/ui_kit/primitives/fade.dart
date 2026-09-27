import 'package:flutter/widgets.dart';

/// Fades [child] in/out on [visible], and stops it from absorbing taps while
/// hidden — for overlay chrome that toggles with a gesture instead of
/// unmounting (e.g. auto-hiding headers/controls).
class AppFade extends StatelessWidget {
  const AppFade({required this.visible, required this.child, super.key});

  static const _animationDuration = Duration(milliseconds: 450);

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    ignoring: !visible,
    child: AnimatedOpacity(
      duration: _animationDuration,
      opacity: visible ? 1 : 0,
      child: child,
    ),
  );
}
