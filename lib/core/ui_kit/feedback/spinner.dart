import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Spinner size, mirroring Forui's [FCircularProgressSizeVariant].
enum AppSpinnerSize { xs, sm, md, lg, xl }

/// An indeterminate loading spinner. Wraps Forui's [FCircularProgress].
class AppSpinner extends StatelessWidget {
  const AppSpinner({this.size = AppSpinnerSize.md, this.color, super.key});

  final AppSpinnerSize size;
  final Color? color;

  static FCircularProgressSizeVariant _size(AppSpinnerSize size) =>
      switch (size) {
        AppSpinnerSize.xs => FCircularProgressSizeVariant.xs,
        AppSpinnerSize.sm => FCircularProgressSizeVariant.sm,
        AppSpinnerSize.md => FCircularProgressSizeVariant.md,
        AppSpinnerSize.lg => FCircularProgressSizeVariant.lg,
        AppSpinnerSize.xl => FCircularProgressSizeVariant.xl,
      };

  @override
  Widget build(BuildContext context) => FCircularProgress(
    size: _size(size),
    style: color == null
        ? const FCircularProgressStyleDelta.context()
        : FCircularProgressStyleDelta.delta(
            iconStyle: IconThemeDataDelta.delta(color: color),
          ),
  );
}
