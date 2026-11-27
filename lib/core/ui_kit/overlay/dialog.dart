import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'barrier.dart';
import 'modal_route.dart';

abstract final class AppDialog {
  static const _insets = EdgeInsets.symmetric(horizontal: 16, vertical: 24);
  static const _constraints = BoxConstraints(minWidth: 280, maxWidth: 480);

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget title,
    Widget? body,
    List<Widget> actions = const [],
    bool barrierDismissible = true,
    bool actionsWrap = true,
    int quarterTurns = 0,
    AppBarrierVariant? barrierVariant,
    String? dismissLabel,
  }) => Navigator.of(context).push(
    AppModalRoute<T>(
      placement: AppModalPlacement.center,
      tokens: context.tokens,
      barrier: AppBarrier.resolve(context, barrierVariant),
      dismissible: barrierDismissible,
      dismissLabel: dismissLabel,
      builder: (context) => SafeArea(
        child: Padding(
          padding: _insets + MediaQuery.viewInsetsOf(context),
          child: Center(
            child: ConstrainedBox(
              constraints: _constraints,
              child: RotatedBox(
                quarterTurns: quarterTurns,
                child: _DialogCard(
                  title: title,
                  body: body,
                  actions: actions,
                  actionsWrap: actionsWrap,
                  compact: quarterTurns != 0,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _DialogCard extends StatelessWidget {
  const _DialogCard({
    required this.title,
    required this.body,
    required this.actions,
    required this.actionsWrap,
    required this.compact,
  });

  final Widget title;
  final Widget? body;
  final List<Widget> actions;
  final bool actionsWrap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = tokens.palette;
    final body = this.body;
    final padding = compact ? AppSpacing.md : AppSpacing.xl - 4;

    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.sheet,
          borderRadius: AppRadii.md,
          boxShadow: tokens.elevation.pop,
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: DefaultTextStyle.merge(
                  style: AppTextStyles.title.copyWith(color: palette.ink),
                  child: title,
                ),
              ),
              if (body != null) ...[
                SizedBox(height: compact ? AppSpacing.xs : AppSpacing.sm),
                Flexible(
                  child: DefaultTextStyle.merge(
                    style: AppTextStyles.body.copyWith(color: palette.ink2),
                    child: body,
                  ),
                ),
              ],
              SizedBox(height: compact ? AppSpacing.md : AppSpacing.xl - 4),
              if (actionsWrap)
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: actions,
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: AppSpacing.sm,
                  children: actions,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
