import 'package:flutter/widgets.dart';

import '../data_display/text.dart';
import '../primitives/tappable.dart';
import '../tokens/app_borders.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../theme/app_tokens.dart';

enum AppRadioVariant { classic, card }

class AppRadioOption<T> {
  const AppRadioOption({required this.value, required this.label});

  final T value;
  final String label;
}

class AppRadioGroup<T> extends StatelessWidget {
  const AppRadioGroup({
    required this.options,
    required this.value,
    required this.onChanged,
    this.variant = AppRadioVariant.classic,
    super.key,
  });

  final List<AppRadioOption<T>> options;
  final T? value;
  final ValueChanged<T> onChanged;
  final AppRadioVariant variant;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: variant == AppRadioVariant.card ? AppSpacing.sm : AppSpacing.xs,
    children: [
      for (final option in options)
        switch (variant) {
          AppRadioVariant.classic => _ClassicOption<T>(
            option: option,
            selected: option.value == value,
            onSelect: () => onChanged(option.value),
          ),
          AppRadioVariant.card => _CardOption<T>(
            option: option,
            selected: option.value == value,
            onSelect: () => onChanged(option.value),
          ),
        },
    ],
  );
}

class _ClassicOption<T> extends StatelessWidget {
  const _ClassicOption({
    required this.option,
    required this.selected,
    required this.onSelect,
  });

  final AppRadioOption<T> option;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) => Semantics(
    inMutuallyExclusiveGroup: true,
    checked: selected,
    child: AppTappable(
      onPressed: onSelect,
      selected: selected,
      semanticsLabel: option.label,
      excludeChildSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.md,
          children: [
            AppRadioDot(selected: selected),
            Flexible(child: AppText(option.label)),
          ],
        ),
      ),
    ),
  );
}

class AppRadioDot extends StatelessWidget {
  const AppRadioDot({required this.selected, super.key});

  static const _size = 22.0;
  static const _dot = 10.0;

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = tokens.palette;
    return AnimatedContainer(
      duration: tokens.motion.quick,
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: palette.sheet,
        border: Border.all(
          color: selected ? palette.ink : palette.ruleStrong,
          width: selected ? 2 : 1.5,
        ),
      ),
      child: AnimatedScale(
        duration: tokens.motion.quick,
        scale: selected ? 1 : 0,
        child: Container(
          width: _dot,
          height: _dot,
          decoration: BoxDecoration(shape: BoxShape.circle, color: palette.ink),
        ),
      ),
    );
  }
}

class _CardOption<T> extends StatelessWidget {
  const _CardOption({
    required this.option,
    required this.selected,
    required this.onSelect,
  });

  final AppRadioOption<T> option;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: AppTappable(
        onPressed: onSelect,
        selected: selected,
        semanticsLabel: option.label,
        excludeChildSemantics: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.sheet,
            borderRadius: AppRadii.md,
            border: Border.all(
              color: selected ? palette.ink : palette.rule,
              width: selected ? AppBorderWidth.thick : AppBorderWidth.thin,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(child: AppText(option.label)),
                AppRadioDot(selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
