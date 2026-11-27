import 'dart:async';

import 'package:flutter/widgets.dart';

import '../primitives/tappable.dart';
import '../theme/app_tokens.dart';
import '../tokens/app_icons.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

enum AppToastVariant { primary, destructive }

@immutable
final class AppToastAction {
  const AppToastAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}

final class AppToastEntry {
  AppToastEntry._(this._dismiss);

  final VoidCallback _dismiss;

  void dismiss() => _dismiss();
}

abstract final class AppToast {
  static AppToastEntry show({
    required BuildContext context,
    required Widget title,
    Widget? description,
    IconData? icon,
    AppToastAction? action,
    AppToastVariant variant = AppToastVariant.primary,
  }) => AppToaster.of(context)._show(
    _ToastData(
      title: title,
      description: description,
      icon:
          icon ??
          (variant == AppToastVariant.destructive
              ? AppIcons.fileWarning
              : null),
      action: action,
    ),
  );
}

final class _ToastData {
  const _ToastData({
    required this.title,
    required this.description,
    required this.icon,
    required this.action,
  });

  final Widget title;
  final Widget? description;
  final IconData? icon;
  final AppToastAction? action;
}

class AppToaster extends StatefulWidget {
  const AppToaster({
    required this.child,
    this.bottomOffset = 88,
    this.visibleFor = const Duration(seconds: 4),
    super.key,
  });

  final Widget child;
  final double bottomOffset;
  final Duration visibleFor;

  static AppToasterState of(BuildContext context) {
    final state = context.findAncestorStateOfType<AppToasterState>();
    assert(state != null, 'AppToast.show needs an AppToaster above it.');
    return state!;
  }

  @override
  State<AppToaster> createState() => AppToasterState();
}

class AppToasterState extends State<AppToaster> {
  _ToastData? _current;
  int _generation = 0;
  Timer? _timer;

  AppToastEntry _show(_ToastData data) {
    _timer?.cancel();
    final generation = ++_generation;
    setState(() => _current = data);
    _timer = Timer(widget.visibleFor, () => _hide(generation));
    return AppToastEntry._(() => _hide(generation));
  }

  void _hide(int generation) {
    if (!mounted || generation != _generation) return;
    _timer?.cancel();
    setState(() => _current = null);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final current = _current;
    final generation = _generation;

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: MediaQuery.paddingOf(context).bottom + widget.bottomOffset,
          child: AnimatedSwitcher(
            duration: tokens.motion.quick,
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.25),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: current == null
                ? const SizedBox.shrink()
                : _Toast(
                    key: ValueKey(generation),
                    data: current,
                    onDismiss: () => _hide(generation),
                  ),
          ),
        ),
      ],
    );
  }
}

class _Toast extends StatelessWidget {
  const _Toast({required this.data, required this.onDismiss, super.key});

  static const _maxWidth = 420.0;

  final _ToastData data;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = tokens.palette;
    final icon = data.icon;
    final description = data.description;
    final action = data.action;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Semantics(
          liveRegion: true,
          container: true,
          child: Dismissible(
            key: const ValueKey('toast'),
            direction: DismissDirection.down,
            onDismissed: (_) => onDismiss(),
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                action == null ? AppSpacing.lg : AppSpacing.sm,
                AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: palette.ink,
                borderRadius: AppRadii.sm,
                boxShadow: tokens.elevation.pop,
              ),
              child: Row(
                spacing: AppSpacing.md,
                children: [
                  if (icon != null) Icon(icon, size: 18, color: palette.onInk),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DefaultTextStyle.merge(
                          style: AppTextStyles.label.copyWith(
                            color: palette.onInk,
                          ),
                          child: data.title,
                        ),
                        if (description != null)
                          DefaultTextStyle.merge(
                            style: AppTextStyles.caption.copyWith(
                              color: palette.onInk.withValues(alpha: 0.72),
                            ),
                            child: description,
                          ),
                      ],
                    ),
                  ),
                  if (action != null)
                    AppTappable(
                      onPressed: () {
                        onDismiss();
                        action.onPressed();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: Text(
                          action.label.toUpperCase(),
                          style: AppTextStyles.overline.copyWith(
                            fontSize: 12,
                            color: palette.onInk,
                            decoration: TextDecoration.underline,
                            decorationColor: palette.onInk,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
