import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../tokens/app_colors.dart';

enum AppTagVariant { standard, success, accent, warning }

class AppTag extends StatelessWidget {
  const AppTag({
    required this.label,
    this.onRemove,
    this.variant = AppTagVariant.standard,
    super.key,
  });

  final Widget label;
  final VoidCallback? onRemove;
  final AppTagVariant variant;

  static (Color, Color)? _customColors(
    BuildContext context,
    AppTagVariant variant,
  ) => switch (variant) {
    AppTagVariant.success => (
      AppColors.success(context),
      AppColors.successForeground(context),
    ),
    AppTagVariant.accent => (
      AppColors.accent(context),
      AppColors.accentForeground(context),
    ),
    AppTagVariant.warning => (
      AppColors.warning(context),
      AppColors.warningForeground(context),
    ),
    AppTagVariant.standard => null,
  };

  @override
  Widget build(BuildContext context) {
    final custom = _customColors(context, variant);
    if (custom == null) {
      return FMultiSelectTag(label: label, onPress: onRemove);
    }

    final (color, foreground) = custom;
    final theme = context.theme;
    final existing = theme.multiSelectStyle.fieldStyles.md.tagStyle;
    final colors = theme.colors.copyWith(
      secondary: color,
      secondaryForeground: foreground,
    );

    return FMultiSelectTag(
      label: label,
      onPress: onRemove,
      style: FMultiSelectTagStyle.inherit(
        colors: colors,
        icons: theme.icons,
        style: theme.style,
        textStyle: theme.typography.body.sm,
        padding: existing.padding,
        borderRadius: theme.style.borderRadius.md,
      ),
    );
  }
}
