import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

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

    final colors = context.theme.colors;
    final radius = AppRadius.of(context).lg;
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.card.withValues(alpha: 0.7),
            border: AppBorders.all(context),
            borderRadius: radius,
          ),
          child: content,
        ),
      ),
    );
  }
}
