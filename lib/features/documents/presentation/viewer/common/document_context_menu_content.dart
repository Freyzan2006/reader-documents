import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/controllers/document_highlights_controller.dart';
import 'package:reader_documents/features/documents/application/providers/selection_tools.dart';
import 'package:reader_documents/features/documents/data/models/document_highlight.dart';
import 'package:reader_documents/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../actions/document_highlight_note_prompt.dart';
import '../../actions/document_quote.dart';
import '../contract/document_text_selection.dart';
import 'document_context_menu.dart';
import 'selection_external_tools.dart';

class DocumentContextMenuContent extends ConsumerWidget {
  const DocumentContextMenuContent({
    required this.selection,
    required this.highlights,
    required this.dismiss,
    required this.documentTitle,
    super.key,
  });

  static const _iconSize = 18.0;

  final DocumentTextSelection selection;
  final DocumentHighlightsController highlights;
  final VoidCallback dismiss;
  final String documentTitle;

  static bool hasEntries(DocumentTextSelection selection) =>
      (selection.isCopyAllowed && selection.hasSelectedText) ||
      !selection.isSelectingAllText ||
      selection.hasSelectedText;

  static String colorLabel(
    AppLocalizations l10n,
    DocumentHighlightColor color,
  ) => switch (color) {
    DocumentHighlightColor.yellow => l10n.contextMenuHighlightYellow,
    DocumentHighlightColor.green => l10n.contextMenuHighlightGreen,
    DocumentHighlightColor.pink => l10n.contextMenuHighlightPink,
  };

  static Future<void> openExternal(
    BuildContext host,
    SelectionExternalTool tool,
    String text,
  ) async {
    if (text.trim().isEmpty) return;
    final languageCode = Localizations.localeOf(host).languageCode;
    if (!tool.prefillsText) {
      await Clipboard.setData(ClipboardData(text: text));
      if (host.mounted) {
        final l10n = AppLocalizations.of(host)!;
        AppToast.show(
          context: host,
          title: Text(l10n.aiTextCopiedTitle),
          description: Text(l10n.aiTextCopiedDescription(tool.label)),
        );
      }
    }
    await launchUrl(
      tool.buildUri(text, languageCode),
      mode: LaunchMode.externalApplication,
    );
  }

  void _copy(BuildContext context) {
    final host = Navigator.of(context).context;
    selection.copyTextSelection();
    dismiss();
    AppToast.show(
      context: host,
      icon: AppIcons.copy,
      title: Text(AppLocalizations.of(host)!.copiedToClipboard),
    );
  }

  Future<void> _addHighlight(
    BuildContext context,
    DocumentHighlightDraft draft,
    DocumentHighlightColor color,
  ) async {
    final host = Navigator.of(context).context;
    final l10n = AppLocalizations.of(context)!;
    final added = highlights.add(draft, color);
    AppToast.show(
      context: host,
      icon: AppIcons.highlighter,
      title: Text(l10n.highlightAddedToast),
      action: AppToastAction(
        label: l10n.undo,
        onPressed: () async => highlights.remove(await added),
      ),
    );
  }

  Future<void> _editNote(
    BuildContext context,
    DocumentHighlightDraft draft,
    DocumentHighlight? existing,
    DocumentHighlightColor color,
  ) async {
    final host = Navigator.of(context).context;
    dismiss();
    final result = await DocumentHighlightNotePrompt.show(
      context: host,
      quote: draft.text,
      note: existing?.note ?? '',
    );
    if (result is! HighlightNoteSaved) return;
    if (existing != null) {
      await highlights.setNote(existing, result.note);
    } else {
      await highlights.add(draft, color, note: result.note.trim());
    }
    if (host.mounted) {
      AppToast.show(
        context: host,
        icon: AppIcons.pencil,
        title: Text(AppLocalizations.of(host)!.highlightNoteSavedToast),
      );
    }
  }

  Future<void> _runExternal(
    BuildContext context,
    SelectionExternalTool tool,
  ) async {
    final host = Navigator.of(context).context;
    final text = await selection.getSelectedText();
    dismiss();
    if (host.mounted) await openExternal(host, tool, text);
  }

  Future<void> _showMore(BuildContext context, SelectionTools tools) async {
    final host = Navigator.of(context).context;
    final notifier = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(selectionToolsProvider.notifier);
    final text = await selection.getSelectedText();
    if (!host.mounted) return;
    final selectAll = selection.isSelectingAllText
        ? null
        : selection.selectAllText;
    final pageNumber = selection.highlightDraft?.pageNumber;
    final canQuote = selection.isCopyAllowed;
    dismiss();
    final picked = await AppSheet.showContent<_MoreResult>(
      context: host,
      dismissLabel: AppLocalizations.of(host)!.contextMenuMoreTitle,
      builder: (sheetContext, scrollController) => _MoreSheet(
        text: text,
        tools: tools,
        canSelectAll: selectAll != null,
        canQuote: canQuote,
        scrollController: scrollController,
      ),
    );
    if (!host.mounted) return;
    final l10n = AppLocalizations.of(host)!;
    String quote() => DocumentQuote.format(
      l10n: l10n,
      text: text,
      title: documentTitle,
      pageNumber: pageNumber,
    );
    switch (picked) {
      case _SelectAll():
        selectAll?.call();
      case _ShareQuote():
        await DocumentQuote.share(quote: quote(), title: documentTitle);
      case _CopyQuote():
        await DocumentQuote.copy(quote());
        if (host.mounted) {
          AppToast.show(
            context: host,
            icon: AppIcons.copy,
            title: Text(l10n.copiedToClipboard),
          );
        }
      case _OpenTool(:final tool):
        await notifier.useProvider(tool.kind, tool.id);
        if (host.mounted) await openExternal(host, tool, text);
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final foreground = context.tokens.palette.ink;
    final tools =
        ref.watch(selectionToolsProvider).value ?? const SelectionTools();
    final toolsNotifier = ref.read(selectionToolsProvider.notifier);
    final primary = <Widget>[];

    final draft = selection.hasSelectedText ? selection.highlightDraft : null;
    final existing = draft == null
        ? null
        : highlights.findOverlapping(
            draft.pageNumber,
            draft.startIndex,
            draft.endIndex,
          );
    if (draft != null) {
      final colors = existing == null
          ? [
              tools.highlightColor,
              for (final color in DocumentHighlightColor.values)
                if (color != tools.highlightColor) color,
            ]
          : DocumentHighlightColor.values;

      for (final color in colors) {
        final current = existing?.color == color;
        primary.add(
          DocumentContextMenuButton(
            icon: DocumentHighlightSwatch(
              color: color.value,
              selected: current,
            ),
            semanticsLabel: colorLabel(l10n, color),
            onPressed: current
                ? null
                : () {
                    if (existing == null) {
                      _addHighlight(context, draft, color);
                    } else {
                      highlights.recolor(existing, color);
                    }
                    toolsNotifier.useHighlightColor(color);
                    dismiss();
                  },
          ),
        );
      }
      if (existing != null) {
        primary.add(
          DocumentContextMenuButton(
            icon: Icon(AppIcons.penOff, size: _iconSize, color: foreground),
            label: l10n.contextMenuRemoveShort,
            semanticsLabel: l10n.removeHighlight,
            onPressed: () {
              highlights.remove(existing);
              dismiss();
            },
          ),
        );
      }
    }

    if (draft != null) {
      primary.add(
        DocumentContextMenuButton(
          icon: Icon(AppIcons.pencil, size: _iconSize, color: foreground),
          label: l10n.contextMenuNote,
          semanticsLabel: existing?.note.isNotEmpty ?? false
              ? l10n.editHighlightNote
              : l10n.contextMenuNote,
          onPressed: () => _editNote(
            context,
            draft,
            existing,
            existing?.color ?? tools.highlightColor,
          ),
        ),
      );
    }

    if (selection.isCopyAllowed && selection.hasSelectedText) {
      primary.add(
        DocumentContextMenuButton(
          icon: Icon(AppIcons.copy, size: _iconSize, color: foreground),
          label: l10n.contextMenuCopy,
          onPressed: () => _copy(context),
        ),
      );
    }

    if (!selection.hasSelectedText && !selection.isSelectingAllText) {
      primary.add(
        DocumentContextMenuButton(
          icon: Icon(AppIcons.textSelect, size: _iconSize, color: foreground),
          label: l10n.contextMenuSelectAll,
          onPressed: selection.selectAllText,
        ),
      );
    }

    final rows = <Widget>[
      if (primary.isNotEmpty) DocumentContextMenuRow(children: primary),
      if (selection.hasSelectedText)
        DocumentContextMenuRow(
          children: [
            for (final kind in SelectionToolKind.values)
              _externalButton(context, l10n, tools, kind, foreground),
            DocumentContextMenuButton(
              icon: Icon(AppIcons.ellipsis, size: _iconSize, color: foreground),
              semanticsLabel: l10n.contextMenuMore,
              onPressed: () => _showMore(context, tools),
            ),
          ],
        ),
    ];

    return DocumentContextMenu(rows: rows);
  }

  Widget _externalButton(
    BuildContext context,
    AppLocalizations l10n,
    SelectionTools tools,
    SelectionToolKind kind,
    Color foreground,
  ) {
    final tool = SelectionExternalTool.preferred(kind, tools);
    final label = SelectionExternalTool.kindLabel(l10n, kind);
    return DocumentContextMenuButton(
      icon: tool.icon(_iconSize, foreground),
      label: label,
      semanticsLabel: l10n.contextMenuOpensIn(label, tool.label),
      external: true,
      onPressed: () => _runExternal(context, tool),
      onLongPress: () => _showMore(context, tools),
    );
  }
}

sealed class _MoreResult {
  const _MoreResult();
}

final class _SelectAll extends _MoreResult {
  const _SelectAll();
}

final class _ShareQuote extends _MoreResult {
  const _ShareQuote();
}

final class _CopyQuote extends _MoreResult {
  const _CopyQuote();
}

final class _OpenTool extends _MoreResult {
  const _OpenTool(this.tool);

  final SelectionExternalTool tool;
}

class _MoreSheet extends StatelessWidget {
  const _MoreSheet({
    required this.text,
    required this.tools,
    required this.canSelectAll,
    required this.canQuote,
    required this.scrollController,
  });

  final String text;
  final SelectionTools tools;
  final bool canSelectAll;
  final bool canQuote;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.tokens.palette;
    final navigator = Navigator.of(context);

    return SingleChildScrollView(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.lg,
        children: [
          AppText(l10n.contextMenuMoreTitle, variant: AppTextVariant.title),
          if (text.trim().isNotEmpty)
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: palette.ruleStrong, width: 3),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: AppSpacing.md),
                child: Text(
                  text.trim(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(color: palette.ink2),
                ),
              ),
            ),
          if (canQuote || canSelectAll)
            AppListGroup(
              children: [
                if (canQuote) ...[
                  AppListRow(
                    title: l10n.pdfMenuShare,
                    leading: AppIcons.share2,
                    onTap: () => navigator.pop(const _ShareQuote()),
                  ),
                  AppListRow(
                    title: l10n.contextMenuCopyQuote,
                    leading: AppIcons.quote,
                    onTap: () => navigator.pop(const _CopyQuote()),
                  ),
                ],
                if (canSelectAll)
                  AppListRow(
                    title: l10n.contextMenuSelectAll,
                    leading: AppIcons.textSelect,
                    onTap: () => navigator.pop(const _SelectAll()),
                  ),
              ],
            ),
          for (final kind in SelectionToolKind.values)
            AppListGroup(
              label: SelectionExternalTool.kindLabel(l10n, kind),
              children: [
                for (final tool in SelectionExternalTool.of(kind))
                  AppListRow(
                    title: tool.label,
                    prefix: SizedBox.square(
                      dimension: 20,
                      child: Center(child: tool.icon(18, palette.ink)),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: AppSpacing.sm,
                      children: [
                        if (SelectionExternalTool.preferred(kind, tools).id ==
                            tool.id)
                          Icon(AppIcons.check, size: 18, color: palette.ink),
                        Icon(
                          AppIcons.arrowUpRight,
                          size: 14,
                          color: palette.ink3,
                        ),
                      ],
                    ),
                    onTap: () => navigator.pop(_OpenTool(tool)),
                  ),
              ],
            ),
          AppText(
            l10n.contextMenuDefaultFootnote,
            variant: AppTextVariant.caption,
          ),
        ],
      ),
    );
  }
}
