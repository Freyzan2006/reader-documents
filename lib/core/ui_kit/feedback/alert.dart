import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';
import '../tokens/app_icons.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

enum AppAlertVariant { primary, destructive }

class AppAlert extends StatelessWidget {
  const AppAlert({
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
    this.variant = AppAlertVariant.primary,
    super.key,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? icon;
  final Widget? action;
  final AppAlertVariant variant;

  bool get _destructive => variant == AppAlertVariant.destructive;

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    final accent = _destructive ? palette.danger : palette.ink;
    final subtitle = this.subtitle;

    return Semantics(
      liveRegion: _destructive,
      container: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: _destructive ? palette.dangerSoft : palette.sheet,
          borderRadius: AppRadii.md,
          border: _destructive ? null : Border.all(color: palette.ruleStrong),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.md,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: IconTheme.merge(
                data: IconThemeData(color: accent, size: 20),
                child:
                    icon ??
                    Icon(_destructive ? AppIcons.fileWarning : AppIcons.info),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  DefaultTextStyle.merge(
                    style: AppTextStyles.item.copyWith(color: accent),
                    child: title,
                  ),
                  if (subtitle != null)
                    DefaultTextStyle.merge(
                      style: AppTextStyles.caption.copyWith(
                        color: _destructive ? palette.ink : palette.ink2,
                      ),
                      child: subtitle,
                    ),
                ],
              ),
            ),
            ?action,
          ],
        ),
      ),
    );
  }
}
