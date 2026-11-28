import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

sealed class HighlightNoteResult {
  const HighlightNoteResult();
}

final class HighlightNoteSaved extends HighlightNoteResult {
  const HighlightNoteSaved(this.note);

  final String note;
}

final class HighlightNoteRemoveHighlight extends HighlightNoteResult {
  const HighlightNoteRemoveHighlight();
}

abstract final class DocumentHighlightNotePrompt {
  static Future<HighlightNoteResult?> show({
    required BuildContext context,
    required String quote,
    String note = '',
    bool canRemoveHighlight = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final inputKey = GlobalKey<_NoteInputState>();
    final navigator = Navigator.of(context);

    return AppDialog.show<HighlightNoteResult>(
      context: context,
      title: Text(l10n.highlightNoteTitle),
      body: _NoteInput(
        key: inputKey,
        quote: quote,
        initial: note,
        hint: l10n.highlightNoteHint,
      ),
      actions: [
        if (canRemoveHighlight)
          AppButton(
            variant: AppButtonVariant.dangerGhost,
            onPressed: () =>
                navigator.pop(const HighlightNoteRemoveHighlight()),
            child: Text(l10n.removeHighlight),
          ),
        AppButton(
          variant: AppButtonVariant.ghost,
          onPressed: navigator.pop,
          child: Text(l10n.cancel),
        ),
        AppButton(
          onPressed: () => navigator.pop(
            HighlightNoteSaved(inputKey.currentState?.text ?? note),
          ),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

class _NoteInput extends StatefulWidget {
  const _NoteInput({
    required this.quote,
    required this.initial,
    required this.hint,
    super.key,
  });

  final String quote;
  final String initial;
  final String hint;

  @override
  State<_NoteInput> createState() => _NoteInputState();
}

class _NoteInputState extends State<_NoteInput> {
  late final _controller = TextEditingController(text: widget.initial);

  String get text => _controller.text;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.md,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: palette.ruleStrong, width: 3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: AppSpacing.md),
            child: Text(
              widget.quote.trim(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(color: palette.ink2),
            ),
          ),
        ),
        AppInput(controller: _controller, hint: widget.hint, autofocus: true),
      ],
    );
  }
}
