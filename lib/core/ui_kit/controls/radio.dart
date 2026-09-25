import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../data_display/text.dart';
import '../tokens/app_borders.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';

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
  Widget build(BuildContext context) => FRadio(
    value: selected,
    onChange: (_) => onSelect(),
    label: Text(option.label),
  );
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
    final colors = context.theme.colors;
    return FTappable(
      onPress: onSelect,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: AppRadius.of(context).md,
          border: Border.all(
            color: selected ? colors.primary : colors.border,
            width: selected ? AppBorderWidth.thick : AppBorderWidth.thin,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(child: AppText(option.label)),
              FRadio(value: selected),
            ],
          ),
        ),
      ),
    );
  }
}
