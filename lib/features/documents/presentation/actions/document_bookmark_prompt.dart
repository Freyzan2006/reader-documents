import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/controllers/document_bookmarks_controller.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

abstract final class DocumentBookmarkPrompt {
  static Future<void> add({
    required BuildContext context,
    required DocumentBookmarksController controller,
    required int pageNumber,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final inputKey = GlobalKey<_BookmarkNoteInputState>();

    final result = await AppDialog.show<String>(
      context: context,
      title: Text(l10n.addBookmarkTitle),
      body: _BookmarkNoteInput(
        key: inputKey,
        label: l10n.bookmarkPageLabel(pageNumber),
        hint: l10n.bookmarkNoteHint,
      ),
      actions: [
        AppButton(
          variant: AppButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        AppButton(
          onPressed: () =>
              Navigator.of(context).pop(inputKey.currentState?.text ?? ''),
          child: Text(l10n.save),
        ),
      ],
    );
    if (result == null) return;
    await controller.add(pageNumber, result);
  }
}

class _BookmarkNoteInput extends StatefulWidget {
  const _BookmarkNoteInput({
    required this.label,
    required this.hint,
    super.key,
  });

  final String label;
  final String hint;

  @override
  State<_BookmarkNoteInput> createState() => _BookmarkNoteInputState();
}

class _BookmarkNoteInputState extends State<_BookmarkNoteInput> {
  final _controller = TextEditingController();

  String get text => _controller.text;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppInput(
    controller: _controller,
    label: widget.label,
    hint: widget.hint,
    autofocus: true,
  );
}
