import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

/// The error state shared by every Home section — the failure mode is the
/// same everywhere (a local repository read failed), only the message
/// differs per section.
class HomeSectionErrorBanner extends StatelessWidget {
  const HomeSectionErrorBanner({
    required this.message,
    required this.error,
    super.key,
  });

  final String message;
  final Object error;

  @override
  Widget build(BuildContext context) => AppAlert(
    title: Text(message),
    subtitle: Text('$error'),
    variant: AppAlertVariant.destructive,
  );
}
