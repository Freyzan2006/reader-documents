import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/document_highlights_controller.dart';
import 'package:reader_documents/features/documents/data/document_highlight.dart';
import 'package:reader_documents/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../contract/document_text_selection.dart';
import 'ai_providers.dart';
import 'document_context_menu.dart';
import 'search_providers.dart';
import 'translate_providers.dart';

class DocumentContextMenuContent extends StatelessWidget {
  const DocumentContextMenuContent({
    required this.selection,
    required this.highlights,
    required this.dismiss,
    super.key,
  });

  static const _actionIconSize = 18.0;

  final DocumentTextSelection selection;
  final DocumentHighlightsController highlights;
  final VoidCallback dismiss;

  static bool hasEntries(DocumentTextSelection selection) =>
      (selection.isCopyAllowed && selection.hasSelectedText) ||
      !selection.isSelectingAllText ||
      selection.hasSelectedText;

  Future<void> _askProvider(BuildContext context, AiProvider provider) async {
    final text = await selection.getSelectedText();
    dismiss();
    if (text.trim().isEmpty) return;

    if (!provider.prefillsText) {
      await Clipboard.setData(ClipboardData(text: text));
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context)!;
      AppToast.show(
        context: context,
        title: Text(l10n.aiTextCopiedTitle),
        description: Text(l10n.aiTextCopiedDescription(provider.label)),
      );
    }

    await launchUrl(
      provider.buildUri(text),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _translateWith(
    TranslateProvider provider,
    String targetLanguageCode,
  ) async {
    final text = await selection.getSelectedText();
    dismiss();
    if (text.trim().isEmpty) return;
    await launchUrl(
      provider.buildUri(text, targetLanguageCode),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _searchWith(SearchProvider provider, String languageCode) async {
    final text = await selection.getSelectedText();
    dismiss();
    if (text.trim().isEmpty) return;
    await launchUrl(
      provider.buildUri(text, languageCode),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final foreground = AppColors.of(context).foreground;
    final entries = <DocumentContextMenuEntry>[];

    if (selection.isCopyAllowed && selection.hasSelectedText) {
      entries.add(
        DocumentContextMenuAction(
          label: l10n.contextMenuCopy,
          icon: Icon(AppIcons.copy, size: _actionIconSize, color: foreground),
          onPressed: () {
            selection.copyTextSelection();
            dismiss();
          },
        ),
      );
    }

    if (!selection.isSelectingAllText) {
      entries.add(
        DocumentContextMenuAction(
          label: l10n.contextMenuSelectAll,
          icon: Icon(
            AppIcons.textSelect,
            size: _actionIconSize,
            color: foreground,
          ),
          onPressed: selection.selectAllText,
        ),
      );
    }

    if (selection.hasSelectedText) {
      final draft = selection.highlightDraft;
      if (draft != null) {
        final existing = highlights.findOverlapping(
          draft.pageNumber,
          draft.startIndex,
          draft.endIndex,
        );

        if (existing != null) {
          entries.add(
            DocumentContextMenuAction(
              label: l10n.removeHighlight,
              icon: Icon(
                AppIcons.penOff,
                size: _actionIconSize,
                color: foreground,
              ),
              onPressed: () {
                highlights.remove(existing);
                dismiss();
              },
            ),
          );
        } else {
          entries.add(
            DocumentContextMenuGroup(
              label: 'Highlight',
              icon: Icon(
                AppIcons.highlighter,
                size: _actionIconSize,
                color: foreground,
              ),
              children: [
                for (final color in DocumentHighlightColor.values)
                  DocumentContextMenuAction(
                    label: color.name,
                    icon: _HighlightSwatch(color: color, size: _actionIconSize),
                    onPressed: () {
                      highlights.add(draft, color);
                      dismiss();
                    },
                  ),
              ],
            ),
          );
        }
      }

      entries.add(
        DocumentContextMenuGroup(
          label: 'AI',
          icon: Icon(
            AppIcons.sparkles,
            size: _actionIconSize,
            color: foreground,
          ),
          children: [
            for (final provider in AiProviders.all)
              DocumentContextMenuAction(
                label: provider.label,
                icon: AiProviderIcon(provider: provider, size: _actionIconSize),
                onPressed: () => _askProvider(context, provider),
              ),
          ],
        ),
      );

      final languageCode = Localizations.localeOf(context).languageCode;
      entries.add(
        DocumentContextMenuGroup(
          label: 'Translate',
          icon: Icon(
            AppIcons.languages,
            size: _actionIconSize,
            color: foreground,
          ),
          children: [
            for (final provider in TranslateProviders.all)
              DocumentContextMenuAction(
                label: provider.label,
                icon: Icon(
                  provider.icon,
                  size: _actionIconSize,
                  color: provider.color,
                ),
                onPressed: () => _translateWith(provider, languageCode),
              ),
          ],
        ),
      );

      entries.add(
        DocumentContextMenuGroup(
          label: 'Search',
          icon: Icon(AppIcons.search, size: _actionIconSize, color: foreground),
          children: [
            for (final provider in SearchProviders.all)
              DocumentContextMenuAction(
                label: provider.label,
                icon: Icon(
                  provider.icon,
                  size: _actionIconSize,
                  color: provider.color ?? foreground,
                ),
                onPressed: () => _searchWith(provider, languageCode),
              ),
          ],
        ),
      );
    }

    return DocumentContextMenu(entries: entries);
  }
}

class _HighlightSwatch extends StatelessWidget {
  const _HighlightSwatch({required this.color, required this.size});

  final DocumentHighlightColor color;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: DecoratedBox(
      decoration: BoxDecoration(color: color.value, shape: BoxShape.circle),
    ),
  );
}
