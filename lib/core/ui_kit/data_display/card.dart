import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../primitives/frosted_surface.dart';
import '../tokens/app_borders.dart';
import '../tokens/app_radius.dart';

enum AppCardVariant { standard, blur }

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding,
    this.variant = AppCardVariant.standard,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final AppCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final style = context.theme.cardStyle;
    final content = Padding(padding: padding ?? style.padding, child: child);

    if (variant == AppCardVariant.standard) {
      return FCard(child: content);
    }

    return AppFrostedSurface(
      color: context.theme.colors.card,
      borderRadius: AppRadius.of(context).lg,
      border: AppBorders.all(context),
      child: content,
    );
  }
}
