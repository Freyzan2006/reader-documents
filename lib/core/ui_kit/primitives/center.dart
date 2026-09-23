import 'package:flutter/widgets.dart';

import '../tokens/app_spacing.dart';

/// A centered layout, like [Center], but with an optional [padding] from
/// [AppSpacing] — centering content flush against the parent's edges is
/// rarely what's wanted, so this saves wrapping every call site in its own
/// [Padding].
class AppCenter extends StatelessWidget {
  const AppCenter({
    required this.child,
    this.padding = AppSpacing.none,
    super.key,
  });

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final center = Center(child: child);
    return padding == AppSpacing.none
        ? center
        : Padding(padding: EdgeInsets.all(padding), child: center);
  }
}
