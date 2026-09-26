import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../tokens/app_colors.dart';

/// Button intent, mirroring Forui's [FButtonVariant] under our own name so
/// screens depend on the ui_kit's vocabulary, not Forui's directly.
enum AppButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  destructive,
  success,
  accent,
  warning,
}

/// Button size, mirroring Forui's [FButtonSizeVariant].
enum AppButtonSize { sm, md, lg }

/// A pressable button. Wraps Forui's [FButton].
class AppButton extends StatelessWidget {
  const AppButton({
    required this.onPressed,
    required this.child,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.mainAxisSize = MainAxisSize.max,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final MainAxisSize mainAxisSize;

  static FButtonVariant _variant(AppButtonVariant variant) => switch (variant) {
    AppButtonVariant.primary => FButtonVariant.primary,
    AppButtonVariant.secondary => FButtonVariant.secondary,
    AppButtonVariant.outline => FButtonVariant.outline,
    AppButtonVariant.ghost => FButtonVariant.ghost,
    AppButtonVariant.destructive => FButtonVariant.destructive,
    // Custom-colored variants reuse the primary shape; their color comes
    // from a recolored FButtonStyle instead of Forui's built-in variants.
    AppButtonVariant.success ||
    AppButtonVariant.accent ||
    AppButtonVariant.warning => FButtonVariant.primary,
  };

  static FButtonSizeVariant _size(AppButtonSize size) => switch (size) {
    AppButtonSize.sm => FButtonSizeVariant.sm,
    AppButtonSize.md => FButtonSizeVariant.md,
    AppButtonSize.lg => FButtonSizeVariant.lg,
  };

  static (Color, Color)? _customColors(
    BuildContext context,
    AppButtonVariant variant,
  ) => switch (variant) {
    AppButtonVariant.success => (
      AppColors.success(context),
      AppColors.successForeground(context),
    ),
    AppButtonVariant.accent => (
      AppColors.accent(context),
      AppColors.accentForeground(context),
    ),
    AppButtonVariant.warning => (
      AppColors.warning(context),
      AppColors.warningForeground(context),
    ),
    _ => null,
  };

  static FButtonStyle _customStyle(
    BuildContext context,
    AppButtonSize size,
    Color color,
    Color foreground,
  ) {
    final theme = context.theme;
    final colors = theme.colors.copyWith(
      primary: color,
      primaryForeground: foreground,
    );
    final sizeStyles = FButtonStyles.inherit(
      colors: colors,
      typography: theme.typography,
      style: theme.style,
      touch: true,
    ).primary;
    return sizeStyles.resolve({_size(size), context.platformVariant});
  }

  @override
  Widget build(BuildContext context) {
    final custom = _customColors(context, variant);

    return FButton(
      onPress: onPressed,
      variant: _variant(variant),
      size: _size(size),
      style: custom == null
          ? const FButtonStyleDelta.context()
          : _customStyle(context, size, custom.$1, custom.$2),
      mainAxisSize: mainAxisSize,
      child: child,
    );
  }
}
