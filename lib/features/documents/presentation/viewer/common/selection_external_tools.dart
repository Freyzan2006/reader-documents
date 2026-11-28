import 'package:flutter/widgets.dart';
import 'package:reader_documents/features/documents/application/providers/selection_tools.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import 'ai_providers.dart';
import 'search_providers.dart';
import 'translate_providers.dart';

final class SelectionExternalTool {
  const SelectionExternalTool({
    required this.kind,
    required this.label,
    required this.icon,
    required this.buildUri,
    this.prefillsText = true,
  });

  final SelectionToolKind kind;
  final String label;
  final Widget Function(double size, Color foreground) icon;
  final Uri Function(String text, String languageCode) buildUri;
  final bool prefillsText;

  String get id => label;

  static String kindLabel(AppLocalizations l10n, SelectionToolKind kind) =>
      switch (kind) {
        SelectionToolKind.translate => l10n.contextMenuTranslate,
        SelectionToolKind.ai => l10n.contextMenuAskAi,
        SelectionToolKind.search => l10n.contextMenuSearch,
      };

  static List<SelectionExternalTool> of(SelectionToolKind kind) =>
      switch (kind) {
        SelectionToolKind.translate => [
          for (final provider in TranslateProviders.all)
            SelectionExternalTool(
              kind: kind,
              label: provider.label,
              icon: (size, _) =>
                  Icon(provider.icon, size: size, color: provider.color),
              buildUri: provider.buildUri,
            ),
        ],
        SelectionToolKind.ai => [
          for (final provider in AiProviders.all)
            SelectionExternalTool(
              kind: kind,
              label: provider.label,
              icon: (size, _) => AiProviderIcon(provider: provider, size: size),
              buildUri: (text, _) => provider.buildUri(text),
              prefillsText: provider.prefillsText,
            ),
        ],
        SelectionToolKind.search => [
          for (final provider in SearchProviders.all)
            SelectionExternalTool(
              kind: kind,
              label: provider.label,
              icon: (size, foreground) => Icon(
                provider.icon,
                size: size,
                color: provider.color ?? foreground,
              ),
              buildUri: provider.buildUri,
            ),
        ],
      };

  static SelectionExternalTool preferred(
    SelectionToolKind kind,
    SelectionTools tools,
  ) {
    final all = of(kind);
    final id = tools.providers[kind];
    return all.firstWhere((tool) => tool.id == id, orElse: () => all.first);
  }
}
