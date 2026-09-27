import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

class DocumentListErrorBanner extends StatelessWidget {
  const DocumentListErrorBanner({required this.error, super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppAlert(
      title: Text(l10n.documentsLoadError),
      subtitle: Text('$error'),
      variant: AppAlertVariant.destructive,
    );
  }
}
