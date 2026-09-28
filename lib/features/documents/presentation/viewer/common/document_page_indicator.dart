import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../contract/document_viewer_controller.dart';

class DocumentPageIndicator extends StatefulWidget {
  const DocumentPageIndicator({required this.controller, super.key});

  final DocumentViewerController? controller;

  @override
  State<DocumentPageIndicator> createState() => _DocumentPageIndicatorState();
}

class _DocumentPageIndicatorState extends State<DocumentPageIndicator> {
  final _pageInputController = TextEditingController();

  @override
  void dispose() {
    _pageInputController.dispose();
    super.dispose();
  }

  void _showGoToPageDialog() {
    final controller = widget.controller;
    if (controller == null) return;

    final l10n = AppLocalizations.of(context)!;
    final currentPage = controller.currentPage ?? 1;
    final totalPages = controller.pageCount;

    _pageInputController.text = currentPage.toString();

    AppDialog.show(
      context: context,
      actionsWrap: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.sm,
        children: [
          Icon(
            AppIcons.fileText,
            size: 20,
            color: AppColors.accent(context),
          ),
          Text(l10n.minimapJumpToPageHint),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: 140,
          child: AppNumberInput(
            controller: _pageInputController,
            hint: l10n.minimapJumpToPageHint,
            min: 1,
            max: totalPages,
            autofocus: true,
            onSubmitted: (value) {
              if (value != null && value >= 1 && value <= totalPages) {
                controller.goToPage(value);
              }
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
      actions: [
        AppTooltip(
          message: l10n.goBack,
          child: AppIconButton(
            icon: AppIcons.arrowLeft,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        AppTooltip(
          message: l10n.minimapJumpToPageHint,
          child: AppIconButton(
            icon: AppIcons.fileText,
            onPressed: () {
              final value = int.tryParse(_pageInputController.text);
              if (value != null && value >= 1 && value <= totalPages) {
                controller.goToPage(value);
              }
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final currentPage = controller?.currentPage;
    if (controller == null || currentPage == null) {
      return const SizedBox.shrink();
    }

    return AppTappable(
      onPressed: _showGoToPageDialog,
      child: AppCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: AppText('$currentPage/${controller.pageCount}'),
      ),
    );
  }
}
