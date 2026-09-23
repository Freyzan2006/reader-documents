import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// A tooltip shown on hover/long-press over [child]. Wraps Forui's
/// [FTooltip].
class AppTooltip extends StatelessWidget {
  const AppTooltip({required this.message, required this.child, super.key});

  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) => FTooltip(
    tipBuilder: (context, controller) => Text(message),
    child: child,
  );
}
