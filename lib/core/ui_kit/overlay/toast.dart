import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Toast intent, mirroring Forui's [FToastVariant].
enum AppToastVariant { primary, destructive }

/// A transient, auto-dismissing status message. Wraps Forui's [showFToast].
///
/// Requires an [FToaster] ancestor — added once in `main.dart`'s
/// `MaterialApp.builder`, not per-screen.
abstract final class AppToast {
  static FToasterEntry show({
    required BuildContext context,
    required Widget title,
    Widget? description,
    AppToastVariant variant = AppToastVariant.primary,
  }) => showFToast(
    context: context,
    title: title,
    description: description,
    variant: switch (variant) {
      AppToastVariant.primary => FToastVariant.primary,
      AppToastVariant.destructive => FToastVariant.destructive,
    },
  );
}
