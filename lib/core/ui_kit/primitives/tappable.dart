import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart' show FTappable;

class AppTappable extends StatelessWidget {
  const AppTappable({
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.selected = false,
    this.semanticsHint,
    super.key,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool selected;
  final String? semanticsHint;

  @override
  Widget build(BuildContext context) => FTappable(
    onPress: onPressed,
    onLongPress: onLongPress,
    selected: selected,
    semanticsHint: semanticsHint,
    child: child,
  );
}
