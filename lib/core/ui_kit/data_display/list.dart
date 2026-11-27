import 'package:flutter/widgets.dart';

import '../controls/icon_button.dart';
import '../primitives/tappable.dart';
import '../theme/app_tokens.dart';
import '../tokens/app_icons.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class AppListItem {
  const AppListItem({
    required this.title,
    this.subtitle,
    this.value,
    this.leading,
    this.trailing,
    this.onTap,
    this.onTrailingTap,
    this.trailingLabel,
    this.destructive = false,
  });

  final String title;
  final String? subtitle;
  final String? value;
  final IconData? leading;
  final IconData? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onTrailingTap;
  final String? trailingLabel;
  final bool destructive;
}

class AppList extends StatelessWidget {
  const AppList({required this.items, this.framed = true, super.key});

  final List<AppListItem> items;
  final bool framed;

  @override
  Widget build(BuildContext context) => AppListGroup(
    framed: framed,
    children: [
      for (final item in items)
        AppListRow(
          title: item.title,
          subtitle: item.subtitle,
          value: item.value,
          leading: item.leading,
          destructive: item.destructive,
          onTap: item.onTap,
          trailing: _trailing(item),
        ),
    ],
  );

  Widget? _trailing(AppListItem item) {
    final icon = item.trailing;
    if (icon == null) return null;
    final onTap = item.onTrailingTap;
    return onTap == null
        ? Icon(icon, size: 18)
        : AppIconButton(
            icon: icon,
            onPressed: onTap,
            semanticsLabel: item.trailingLabel,
          );
  }
}

class AppListGroup extends StatelessWidget {
  const AppListGroup({
    required this.children,
    this.label,
    this.framed = true,
    super.key,
  });

  static const _dividerIndent = 52.0;

  final List<Widget> children;
  final String? label;
  final bool framed;

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    final label = this.label;
    final rows = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, child) in children.indexed) ...[
          if (index > 0)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: _dividerIndent),
              child: SizedBox(
                height: 1,
                width: double.infinity,
                child: ColoredBox(color: palette.rule),
              ),
            ),
          child,
        ],
      ],
    );

    final body = framed
        ? DecoratedBox(
            decoration: BoxDecoration(
              color: palette.sheet,
              borderRadius: AppRadii.md,
              border: Border.all(color: palette.rule),
            ),
            child: ClipRRect(borderRadius: AppRadii.md, child: rows),
          )
        : rows;

    if (label == null) return body;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.sm,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Semantics(
            header: true,
            child: Text(
              label.toUpperCase(),
              style: AppTextStyles.overline.copyWith(color: palette.ink3),
            ),
          ),
        ),
        body,
      ],
    );
  }
}

class AppListRow extends StatelessWidget {
  const AppListRow({
    required this.title,
    this.subtitle,
    this.value,
    this.leading,
    this.prefix,
    this.trailing,
    this.onTap,
    this.chevron = false,
    this.destructive = false,
    this.highlighted = false,
    this.match,
    super.key,
  });

  static const _minHeight = 52.0;

  final String title;
  final String? subtitle;
  final String? value;
  final IconData? leading;
  final Widget? prefix;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool chevron;
  final bool destructive;
  final bool highlighted;
  final String? match;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = tokens.palette;
    final ink = destructive ? palette.danger : palette.ink;
    final subtitle = this.subtitle;
    final value = this.value;
    final leading = this.leading;

    return AppTappable.builder(
      onPressed: onTap,
      builder: (context, state) => AnimatedContainer(
        duration: tokens.motion.quick,
        constraints: const BoxConstraints(minHeight: _minHeight),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        color: state.pressed || highlighted
            ? palette.shade
            : const Color(0x00000000),
        child: IconTheme.merge(
          data: IconThemeData(color: destructive ? ink : palette.ink3),
          child: Row(
            spacing: AppSpacing.md,
            children: [
              ?prefix,
              if (leading != null && prefix == null)
                Icon(
                  leading,
                  size: 20,
                  color: destructive ? ink : palette.ink2,
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _HighlightedTitle(
                      title: title,
                      match: match,
                      style: AppTextStyles.body.copyWith(color: ink),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: AppTextStyles.caption.copyWith(
                          color: palette.ink3,
                        ),
                      ),
                  ],
                ),
              ),
              if (value != null)
                Text(
                  value,
                  style: AppTextStyles.meta.copyWith(color: palette.ink3),
                ),
              ?trailing,
              if (chevron) const Icon(AppIcons.chevronRight, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _HighlightedTitle extends StatelessWidget {
  const _HighlightedTitle({
    required this.title,
    required this.style,
    this.match,
  });

  final String title;
  final String? match;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final match = this.match?.trim() ?? '';
    final start = match.isEmpty
        ? -1
        : title.toLowerCase().indexOf(match.toLowerCase());
    if (start < 0) return Text(title, style: style);
    final end = start + match.length;
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: title.substring(0, start)),
          TextSpan(
            text: title.substring(start, end),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: title.substring(end)),
        ],
      ),
    );
  }
}
