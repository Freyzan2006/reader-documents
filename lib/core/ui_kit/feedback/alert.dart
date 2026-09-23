import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Alert intent, mirroring Forui's [FAlertVariant].
enum AppAlertVariant { primary, destructive }

/// An inline banner for persistent, non-transient feedback (as opposed to
/// [AppToast], which is transient and floats above content). Wraps Forui's
/// [FAlert].
class AppAlert extends StatelessWidget {
  const AppAlert({
    required this.title,
    this.subtitle,
    this.icon,
    this.variant = AppAlertVariant.primary,
    super.key,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? icon;
  final AppAlertVariant variant;

  @override
  Widget build(BuildContext context) => FAlert(
    title: title,
    subtitle: subtitle,
    icon: icon,
    variant: switch (variant) {
      AppAlertVariant.primary => FAlertVariant.primary,
      AppAlertVariant.destructive => FAlertVariant.destructive,
    },
  );
}
