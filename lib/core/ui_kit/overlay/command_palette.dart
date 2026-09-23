import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../controls/input.dart';
import '../data_display/text.dart';
import '../layout/divider.dart';
import '../tokens/app_spacing.dart';

/// A single command: its label and what happens when it's chosen.
class AppCommandItem {
  const AppCommandItem({
    required this.label,
    required this.onSelect,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onSelect;
}

/// A searchable, keyboard-navigable list of commands presented as a dialog —
/// the "Cmd+K" pattern. Forui has no equivalent widget; this is built from
/// [AppInput] (search), Forui's [FTileGroup]/[FTile] (results, for their
/// built-in `selected` highlight styling) and [showFDialog]/[FDialog] for
/// presentation (which, unlike [FSheetStyle], does have its own background
/// decoration — no extra chrome needed here).
///
/// Filtering is a case-insensitive substring match on each item's label.
/// Arrow keys move the highlighted row, Enter selects it, Escape closes the
/// palette — wired via [CallbackShortcuts], so typing into the search field
/// keeps working normally alongside them.
abstract final class AppCommandPalette {
  static Future<void> show({
    required BuildContext context,
    required List<AppCommandItem> items,
    String hint = 'Type a command…',
  }) => showFDialog<void>(
    context: context,
    builder: (context, style, animation) => FDialog(
      style: style,
      animation: animation,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 480),
      builder: (context, style) =>
          _CommandPaletteContent(items: items, hint: hint),
    ),
  );
}

class _CommandPaletteContent extends StatefulWidget {
  const _CommandPaletteContent({required this.items, required this.hint});

  final List<AppCommandItem> items;
  final String hint;

  @override
  State<_CommandPaletteContent> createState() => _CommandPaletteContentState();
}

class _CommandPaletteContentState extends State<_CommandPaletteContent> {
  final _controller = TextEditingController();
  int _highlighted = 0;
  late List<AppCommandItem> _filtered = widget.items;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) => setState(() {
    _filtered = query.isEmpty
        ? widget.items
        : widget.items
              .where(
                (item) =>
                    item.label.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    _highlighted = 0;
  });

  void _move(int delta) {
    if (_filtered.isEmpty) return;
    setState(
      () => _highlighted =
          (_highlighted + delta + _filtered.length) % _filtered.length,
    );
  }

  void _selectHighlighted() {
    if (_filtered.isEmpty) return;
    _select(_filtered[_highlighted]);
  }

  void _select(AppCommandItem item) {
    Navigator.of(context).pop();
    item.onSelect();
  }

  @override
  Widget build(BuildContext context) => CallbackShortcuts(
    bindings: {
      const SingleActivator(LogicalKeyboardKey.arrowDown): () => _move(1),
      const SingleActivator(LogicalKeyboardKey.arrowUp): () => _move(-1),
      const SingleActivator(LogicalKeyboardKey.enter): _selectHighlighted,
      const SingleActivator(LogicalKeyboardKey.escape): () =>
          Navigator.of(context).pop(),
    },
    child: Focus(
      autofocus: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppInput(
              controller: _controller,
              hint: widget.hint,
              autofocus: true,
              onChanged: _onQueryChanged,
            ),
          ),
          const AppDivider(),
          if (_filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: AppText('No results', variant: AppTextVariant.caption),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: FTileGroup(
                children: [
                  for (final (index, item) in _filtered.indexed)
                    FTile(
                      selected: index == _highlighted,
                      title: Text(item.label),
                      prefix: item.icon == null ? null : Icon(item.icon),
                      onPress: () => _select(item),
                    ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}
