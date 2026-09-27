import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../contract/document_viewer_controller.dart';

class DocumentViewerSearchBar extends StatelessWidget {
  const DocumentViewerSearchBar({
    required this.controller,
    required this.session,
    required this.onClose,
    super.key,
  });

  final TextEditingController controller;
  final DocumentSearchSession? session;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasMatches = session?.hasMatches ?? false;

    return Row(
      spacing: AppSpacing.sm,
      children: [
        AppIconButton(icon: AppIcons.x, onPressed: onClose),
        Expanded(
          child: AppInput(
            controller: controller,
            hint: l10n.pdfSearchHint,
            autofocus: true,
            enabled: !(session?.isPreparing ?? false),
            onChanged: session?.startTextSearch,
          ),
        ),
        if (session?.isPreparing ?? false)
          const AppSpinner(size: AppSpinnerSize.sm),
        if (hasMatches)
          AppBadge(
            variant: AppBadgeVariant.secondary,
            child: Text('${session!.currentIndex! + 1}/${session!.matchCount}'),
          ),
        AppIconButton(
          icon: AppIcons.chevronUp,
          onPressed: hasMatches ? session!.goToPrevMatch : null,
        ),
        AppIconButton(
          icon: AppIcons.chevronDown,
          onPressed: hasMatches ? session!.goToNextMatch : null,
        ),
      ],
    );
  }
}
