import 'package:flutter/widgets.dart';

import '../controls/checkbox.dart';
import '../controls/icon_button.dart';
import '../feedback/progress.dart';
import '../primitives/tappable.dart';
import '../theme/app_tokens.dart';
import '../tokens/app_icons.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'badge.dart';
import 'text.dart';

final class AppPageRatio {
  const AppPageRatio._();

  static const widthToHeight = 1 / 1.414;
}

class AppPageThumbnail extends StatelessWidget {
  const AppPageThumbnail({
    this.image,
    this.format,
    this.progress,
    this.favorite = false,
    this.selected,
    this.scanned = false,
    this.borderRadius = AppRadii.sm,
    this.fill = false,
    super.key,
  });

  final Widget? image;
  final String? format;
  final double? progress;
  final bool favorite;
  final bool? selected;
  final bool scanned;
  final BorderRadius borderRadius;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    final format = this.format;
    final progress = this.progress;
    final selected = this.selected;
    final isSelected = selected ?? false;

    final sheet = DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(
          color: isSelected ? palette.ink : palette.rule,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: scanned ? palette.shade : palette.sheet),
            const _PagePlaceholder(),
            ?image,
            if (format != null)
              Positioned(
                left: 6,
                top: 6,
                child: AppBadge(
                  variant: AppBadgeVariant.outline,
                  child: Text(format.toUpperCase()),
                ),
              ),
            if (selected != null)
              Positioned(
                right: 6,
                top: 6,
                child: AppCheckMark(checked: selected, round: true, size: 20),
              )
            else if (favorite)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: palette.sheet,
                    shape: BoxShape.circle,
                    border: Border.all(color: palette.rule),
                  ),
                  child: Icon(AppIcons.star, size: 14, color: palette.ink),
                ),
              ),
            if (progress != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AppProgress(value: progress, height: 3),
              ),
          ],
        ),
      ),
    );
    return fill
        ? sheet
        : AspectRatio(aspectRatio: AppPageRatio.widthToHeight, child: sheet);
  }
}

class _PagePlaceholder extends StatelessWidget {
  const _PagePlaceholder();

  static const _widths = [0.62, 1, 1, 0.84, 0.46, 1, 1, 0.84, 1, 0.46];

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth * 0.76;
        final height = constraints.maxHeight;
        final headLine = (height * 0.035).clamp(1.5, 5.0);
        final bodyLine = (height * 0.022).clamp(1.0, 3.0);
        return Padding(
          padding: EdgeInsets.fromLTRB(
            constraints.maxWidth * 0.12,
            constraints.maxHeight * 0.12,
            constraints.maxWidth * 0.12,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: constraints.maxHeight * 0.03,
            children: [
              for (final (index, factor) in _widths.indexed)
                Container(
                  width: width * factor,
                  height: index == 0 ? headLine : bodyLine,
                  decoration: BoxDecoration(
                    color: index == 0
                        ? palette.ruleStrong
                        : palette.shadeStrong,
                    borderRadius: BorderRadius.circular(bodyLine),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class AppDocumentCard extends StatelessWidget {
  const AppDocumentCard({
    required this.title,
    required this.meta,
    this.format,
    this.thumbnail,
    this.progress,
    this.favorite = false,
    this.selected,
    this.scanned = false,
    this.onTap,
    this.onLongPress,
    this.semanticsHint,
    super.key,
  });

  final String title;
  final String meta;
  final String? format;
  final Widget? thumbnail;
  final double? progress;
  final bool favorite;
  final bool? selected;
  final bool scanned;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semanticsHint;

  @override
  Widget build(BuildContext context) => AppTappable(
    onPressed: onTap,
    onLongPress: onLongPress,
    selected: selected ?? false,
    semanticsHint: semanticsHint,
    pressedOpacity: 0.8,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.sm,
      children: [
        AppPageThumbnail(
          image: thumbnail,
          format: format,
          progress: progress,
          favorite: favorite,
          selected: selected,
          scanned: scanned,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            AppText(
              title,
              variant: AppTextVariant.item,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            AppText(
              meta,
              variant: AppTextVariant.meta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    ),
  );
}

class AppDocumentRow extends StatelessWidget {
  const AppDocumentRow({
    required this.title,
    required this.meta,
    this.format,
    this.thumbnail,
    this.progress,
    this.favorite = false,
    this.selected,
    this.scanned = false,
    this.onTap,
    this.onLongPress,
    this.onMore,
    this.moreLabel,
    this.semanticsHint,
    super.key,
  });

  static const _thumbWidth = 42.0;
  static const _minHeight = 76.0;

  final String title;
  final String meta;
  final String? format;
  final Widget? thumbnail;
  final double? progress;
  final bool favorite;
  final bool? selected;
  final bool scanned;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onMore;
  final String? moreLabel;
  final String? semanticsHint;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = tokens.palette;
    final selected = this.selected;
    final format = this.format;
    final progress = this.progress;
    final onMore = this.onMore;

    return AppTappable(
      onPressed: onTap,
      onLongPress: onLongPress,
      selected: selected ?? false,
      semanticsHint: semanticsHint,
      pressedOpacity: 0.8,
      child: AnimatedContainer(
        duration: tokens.motion.quick,
        constraints: const BoxConstraints(minHeight: _minHeight),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        color: selected ?? false ? palette.shade : const Color(0x00000000),
        child: Row(
          spacing: AppSpacing.md,
          children: [
            if (selected != null)
              AppCheckMark(checked: selected, round: true, size: 20),
            SizedBox(
              width: _thumbWidth,
              child: AppPageThumbnail(
                image: thumbnail,
                scanned: scanned,
                borderRadius: AppRadii.xs,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  AppText(
                    title,
                    variant: AppTextVariant.item,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    spacing: 6,
                    children: [
                      if (format != null)
                        AppBadge(
                          variant: AppBadgeVariant.outline,
                          child: Text(format.toUpperCase()),
                        ),
                      if (favorite)
                        Icon(AppIcons.star, size: 12, color: palette.ink),
                      Flexible(
                        child: AppText(
                          meta,
                          variant: AppTextVariant.meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (progress != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 160),
                        child: AppProgress(value: progress, height: 3),
                      ),
                    ),
                ],
              ),
            ),
            if (onMore != null && selected == null)
              AppIconButton(
                icon: AppIcons.ellipsisVertical,
                onPressed: onMore,
                semanticsLabel: moreLabel,
              ),
          ],
        ),
      ),
    );
  }
}

class AppContinueReadingCard extends StatelessWidget {
  const AppContinueReadingCard({
    required this.overline,
    required this.title,
    required this.meta,
    this.progress,
    this.thumbnail,
    this.onTap,
    super.key,
  });

  static const _thumbWidth = 72.0;

  final String overline;
  final String title;
  final String meta;
  final double? progress;
  final Widget? thumbnail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    final progress = this.progress;
    return AppTappable(
      onPressed: onTap,
      pressedOpacity: 0.85,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: palette.sheet,
          borderRadius: AppRadii.md,
          border: Border.all(color: palette.rule),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.lg,
            children: [
              SizedBox(
                width: _thumbWidth,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: AppPageThumbnail(
                    image: thumbnail,
                    borderRadius: AppRadii.xs,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    AppText(overline, variant: AppTextVariant.overline),
                    AppText(
                      title,
                      variant: AppTextVariant.item,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppText(meta, variant: AppTextVariant.meta),
                    const Spacer(),
                    if (progress != null)
                      Row(
                        spacing: AppSpacing.md,
                        children: [
                          Expanded(child: AppProgress(value: progress)),
                          Text(
                            '${(progress.clamp(0.0, 1.0) * 100).round()}%',
                            style: AppTextStyles.meta.copyWith(
                              color: palette.ink2,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
