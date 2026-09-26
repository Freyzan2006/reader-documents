import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../application/documents_providers.dart';
import '../data/document_file.dart';

abstract final class DocumentRename {
  static Future<void> show({
    required BuildContext context,
    required WidgetRef ref,
    required DocumentFile file,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final currentTitle =
        ref.read(documentTitleProvider(file.path)) ?? file.name;
    final inputKey = GlobalKey<_RenameInputState>();

    final result = await AppDialog.show<String>(
      context: context,
      title: Text(l10n.renameDocumentTitle),
      body: _RenameInput(
        key: inputKey,
        initialText: currentTitle,
        hint: l10n.renameDocumentHint,
      ),
      actions: [
        AppButton(
          variant: AppButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        AppButton(
          onPressed: () =>
              Navigator.of(context).pop(inputKey.currentState?.text),
          child: Text(l10n.save),
        ),
      ],
    );
    if (result == null) return;
    await ref.read(documentTitlesProvider.notifier).setTitle(file.path, result);
  }
}

class _RenameInput extends StatefulWidget {
  const _RenameInput({
    required this.initialText,
    required this.hint,
    super.key,
  });

  final String initialText;
  final String hint;

  @override
  State<_RenameInput> createState() => _RenameInputState();
}

class _RenameInputState extends State<_RenameInput> {
  late final _controller = TextEditingController(text: widget.initialText);

  String get text => _controller.text;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      AppInput(controller: _controller, hint: widget.hint, autofocus: true);
}
