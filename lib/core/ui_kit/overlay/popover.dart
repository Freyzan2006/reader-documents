import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class AppPopover extends StatelessWidget {
  const AppPopover({
    required this.popoverBuilder,
    required this.child,
    super.key,
  });

  final WidgetBuilder popoverBuilder;
  final Widget child;

  @override
  Widget build(BuildContext context) => FPopover(
    popoverBuilder: (context, controller) => popoverBuilder(context),
    builder: (context, controller, child) =>
        FTappable(onPress: controller.toggle, child: child!),
    child: child,
  );
}
