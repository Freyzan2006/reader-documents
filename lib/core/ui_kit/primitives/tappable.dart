import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart' show FTappable;

class AppTappable extends StatelessWidget {
  const AppTappable({required this.child, this.onPressed, super.key});

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) =>
      FTappable(onPress: onPressed, child: child);
}
