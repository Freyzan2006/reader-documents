import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// A padded content card. Wraps Forui's [FCard], adding the padding Forui's
/// own snippet generator applies (`dart run forui snippet create card`) —
/// [FCard] itself ships unpadded.
class AppCard extends StatelessWidget {
  const AppCard({required this.child, this.padding, super.key});

  final Widget child;

  /// Defaults to `context.theme.cardStyle.padding`, so it scales with touch
  /// vs. desktop the same way Forui's own widgets do.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final style = context.theme.cardStyle;
    return FCard(child: Padding(padding: padding ?? style.padding, child: child));
  }
}
