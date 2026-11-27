import 'package:flutter/widgets.dart';

import '../controls/radio.dart';
import '../data_display/list.dart';
import '../theme/app_tokens.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'sheet.dart';

class AppChoice<T> {
  const AppChoice({
    required this.value,
    required this.title,
    this.subtitle,
    this.code,
  });

  final T value;
  final String title;
  final String? subtitle;
  final String? code;
}

abstract final class AppChoiceSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<AppChoice<T>> choices,
    required T selected,
    String? meta,
    String? footnote,
  }) => AppSheet.showContent<T>(
    context: context,
    dismissLabel: title,
    builder: (sheetContext, scrollController) => _ChoiceSheetView<T>(
      title: title,
      meta: meta,
      footnote: footnote,
      choices: choices,
      selected: selected,
      scrollController: scrollController,
    ),
  );
}

class _ChoiceSheetView<T> extends StatelessWidget {
  const _ChoiceSheetView({
    required this.title,
    required this.choices,
    required this.selected,
    required this.scrollController,
    this.meta,
    this.footnote,
  });

  final String title;
  final String? meta;
  final String? footnote;
  final List<AppChoice<T>> choices;
  final T selected;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    final meta = this.meta;
    final footnote = this.footnote;

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            spacing: AppSpacing.md,
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: AppTextStyles.title.copyWith(color: palette.ink),
                  ),
                ),
              ),
              if (meta != null)
                Text(
                  meta,
                  style: AppTextStyles.meta.copyWith(color: palette.ink3),
                ),
            ],
          ),
          AppListGroup(
            children: [
              for (final choice in choices)
                _ChoiceRow<T>(
                  choice: choice,
                  selected: choice.value == selected,
                ),
            ],
          ),
          if (footnote != null)
            Text(
              footnote,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(color: palette.ink3),
            ),
        ],
      ),
    );
  }
}

class _ChoiceRow<T> extends StatelessWidget {
  const _ChoiceRow({required this.choice, required this.selected});

  static const _codeWidth = 24.0;

  final AppChoice<T> choice;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    final code = choice.code;

    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: AppListRow(
        title: choice.title,
        subtitle: choice.subtitle,
        prefix: AppRadioDot(selected: selected),
        trailing: code == null
            ? null
            : SizedBox(
                width: _codeWidth,
                child: Text(
                  code,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.meta.copyWith(
                    color: palette.ink3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
        onTap: () => Navigator.of(context).pop(choice.value),
      ),
    );
  }
}
