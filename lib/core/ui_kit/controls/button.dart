import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Button intent, mirroring Forui's [FButtonVariant] under our own name so
/// screens depend on the ui_kit's vocabulary, not Forui's directly.
enum AppButtonVariant { primary, secondary, outline, ghost, destructive }

/// Button size, mirroring Forui's [FButtonSizeVariant].
enum AppButtonSize { sm, md, lg }

/// A pressable button. Wraps Forui's [FButton].
class AppButton extends StatelessWidget {
  const AppButton({
    required this.onPressed,
    required this.child,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final AppButtonVariant variant;
  final AppButtonSize size;

  static FButtonVariant _variant(AppButtonVariant variant) => switch (variant) {
    AppButtonVariant.primary => FButtonVariant.primary,
    AppButtonVariant.secondary => FButtonVariant.secondary,
    AppButtonVariant.outline => FButtonVariant.outline,
    AppButtonVariant.ghost => FButtonVariant.ghost,
    AppButtonVariant.destructive => FButtonVariant.destructive,
  };

  static FButtonSizeVariant _size(AppButtonSize size) => switch (size) {
    AppButtonSize.sm => FButtonSizeVariant.sm,
    AppButtonSize.md => FButtonSizeVariant.md,
    AppButtonSize.lg => FButtonSizeVariant.lg,
  };

  @override
  Widget build(BuildContext context) =>
      FButton(onPress: onPressed, variant: _variant(variant), size: _size(size), child: child);
}
