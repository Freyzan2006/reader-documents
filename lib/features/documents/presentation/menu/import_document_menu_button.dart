import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

class ImportDocumentMenuButton extends StatelessWidget {
  const ImportDocumentMenuButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => AppButton(
    variant: AppButtonVariant.outline,
    onPressed: onPressed,
    prefix: const Icon(AppIcons.upload),
    flexibleChild: true,
    child: Text(
      AppLocalizations.of(context)!.importDocument,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
}
