import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../../application/documents_providers.dart';

class DocumentGestureHintBanner extends ConsumerStatefulWidget {
  const DocumentGestureHintBanner({super.key});

  @override
  ConsumerState<DocumentGestureHintBanner> createState() =>
      _DocumentGestureHintBannerState();
}

class _DocumentGestureHintBannerState
    extends ConsumerState<DocumentGestureHintBanner> {
  static const _duration = Duration(seconds: 7);

  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _dismiss() {
    _timer?.cancel();
    _timer = null;
    ref.read(gestureHintSeenProvider.notifier).markSeen();
  }

  void _updateTimer({required bool visible}) {
    if (!visible) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    _timer ??= Timer(_duration, _dismiss);
  }

  @override
  Widget build(BuildContext context) {
    final seen = ref.watch(gestureHintSeenProvider).value ?? true;
    final visible = !seen && TickerMode.valuesOf(context).enabled;
    _updateTimer(visible: visible);
    if (seen) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.mousePointerClick,
            size: 20,
            color: context.tokens.palette.ink,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xs,
              children: [
                AppText(
                  l10n.gestureHintLongPress,
                  variant: AppTextVariant.body,
                ),
                AppText(l10n.gestureHintSwipe, variant: AppTextVariant.caption),
              ],
            ),
          ),
          AppIconButton(
            icon: AppIcons.x,
            onPressed: _dismiss,
            semanticsLabel: l10n.cancel,
          ),
        ],
      ),
    );
  }
}
