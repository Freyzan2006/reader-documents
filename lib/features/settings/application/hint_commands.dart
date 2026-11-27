import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/providers/gesture_hint.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

abstract final class HintCommands {
  static Future<void> resetAll(BuildContext context, WidgetRef ref) async {
    await ref.read(gestureHintSeenProvider.notifier).reset();
    if (!context.mounted) return;
    AppToast.show(
      context: context,
      title: Text(AppLocalizations.of(context)!.hintsResetToast),
    );
  }
}
