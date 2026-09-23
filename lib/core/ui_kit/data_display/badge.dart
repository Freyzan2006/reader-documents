import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Badge intent, mirroring Forui's [FBadgeVariant].
enum AppBadgeVariant { primary, secondary, outline, destructive }

/// A small status/count indicator. Wraps Forui's [FBadge].
class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.child,
    this.variant = AppBadgeVariant.primary,
    super.key,
  });

  final Widget child;
  final AppBadgeVariant variant;

  @override
  Widget build(BuildContext context) => FBadge(
    variant: switch (variant) {
      AppBadgeVariant.primary => FBadgeVariant.primary,
      AppBadgeVariant.secondary => FBadgeVariant.secondary,
      AppBadgeVariant.outline => FBadgeVariant.outline,
      AppBadgeVariant.destructive => FBadgeVariant.destructive,
    },
    child: child,
  );
}
