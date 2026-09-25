import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../controls/input.dart';
import '../data_display/text.dart';
import '../layout/divider.dart';
import '../tokens/app_spacing.dart';
import 'sheet.dart';

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

class AppCommandGroup {
  const AppCommandGroup({required this.label, required this.items});

  final String label;
  final List<AppCommandItem> items;
}

abstract final class AppCommandPalette {
  static const _maxRecent = 5;

  static final List<String> _recentLabels = [];

  static Future<void> show({
    required BuildContext context,
    required List<AppCommandGroup> groups,
    String hint = 'Type a command…',
    String recentLabel = 'Recent',
    String noResultsLabel = 'No results',
  }) => AppSheet.show<void>(
    context: context,
    initialSize: 0.75,
    minSize: 0.4,
    maxSize: 0.95,
    builder: (context, scrollController) => _CommandPaletteContent(
      groups: groups,
      hint: hint,
      recentLabel: recentLabel,
      noResultsLabel: noResultsLabel,
      scrollController: scrollController,
    ),
  );

  static void _recordRecent(String label) {
    _recentLabels
      ..remove(label)
      ..insert(0, label);
    if (_recentLabels.length > _maxRecent) {
      _recentLabels.removeRange(_maxRecent, _recentLabels.length);
    }
  }
}

class _CommandPaletteContent extends StatefulWidget {
  const _CommandPaletteContent({
    required this.groups,
    required this.hint,
    required this.recentLabel,
    required this.noResultsLabel,
    required this.scrollController,
  });

  final List<AppCommandGroup> groups;
  final String hint;
  final String recentLabel;
  final String noResultsLabel;
  final ScrollController scrollController;

  @override
  State<_CommandPaletteContent> createState() => _CommandPaletteContentState();
}

class _CommandPaletteContentState extends State<_CommandPaletteContent> {
  final _controller = TextEditingController();
  int _highlighted = 0;
  String _query = '';
  Set<int> _expandedGroups = {};
  late List<AppCommandItem> _recent;
  late List<AppCommandItem> _searchResults;

  List<AppCommandItem> get _allItems => [
    for (final group in widget.groups) ...group.items,
  ];

  @override
  void initState() {
    super.initState();
    _expandedGroups = {for (var i = 0; i < widget.groups.length; i++) i};
    _applyQuery('');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applyQuery(String query) {
    _query = query;
    if (query.isEmpty) {
      final byLabel = {for (final item in _allItems) item.label: item};
      _recent = [
        for (final label in AppCommandPalette._recentLabels) ?byLabel[label],
      ];
      _searchResults = const [];
    } else {
      _recent = const [];
      final lower = query.toLowerCase();
      _searchResults = _allItems
          .where((item) => item.label.toLowerCase().contains(lower))
          .toList();
    }
  }

  List<AppCommandItem> _groupItems(int groupIndex) {
    final recentLabels = _recent.map((item) => item.label).toSet();
    return widget.groups[groupIndex].items
        .where((item) => !recentLabels.contains(item.label))
        .toList();
  }

  List<AppCommandItem> get _visible {
    if (_query.isNotEmpty) return _searchResults;
    final visible = [..._recent];
    for (var i = 0; i < widget.groups.length; i++) {
      if (_expandedGroups.contains(i)) visible.addAll(_groupItems(i));
    }
    return visible;
  }

  void _onQueryChanged(String query) => setState(() {
    _applyQuery(query);
    _highlighted = 0;
  });

  void _move(int delta) {
    final visible = _visible;
    if (visible.isEmpty) return;
    setState(
      () => _highlighted =
          (_highlighted + delta + visible.length) % visible.length,
    );
  }

  void _selectHighlighted() {
    final visible = _visible;
    if (visible.isEmpty) return;
    _select(visible[_highlighted]);
  }

  void _select(AppCommandItem item) {
    AppCommandPalette._recordRecent(item.label);
    Navigator.of(context).pop();
    item.onSelect();
  }

  FTile _tile(AppCommandItem item, int index) => FTile(
    style: FItemStyleDelta.delta(
      padding: EdgeInsetsGeometryDelta.add(
        const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      ),
    ),
    selected: index == _highlighted,
    title: Text(item.label),
    prefix: item.icon == null ? null : Icon(item.icon),
    onPress: () => _select(item),
  );

  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(0, AppSpacing.sm, 0, AppSpacing.xs),
    child: AppText(label, variant: AppTextVariant.caption),
  );

  List<Widget> _buildGroupedContent() {
    var cursor = _recent.length;

    return [
      if (_recent.isNotEmpty) ...[
        _sectionLabel(widget.recentLabel),
        FTileGroup(
          children: [
            for (final (index, item) in _recent.indexed) _tile(item, index),
          ],
        ),
      ],
      FAccordion(
        control: FAccordionControl.lifted(
          expanded: (index) => _expandedGroups.contains(index),
          onChange: (index, expanded) => setState(() {
            if (expanded) {
              _expandedGroups.add(index);
            } else {
              _expandedGroups.remove(index);
            }
          }),
        ),
        children: [
          for (final (groupIndex, group) in widget.groups.indexed)
            () {
              final items = _groupItems(groupIndex);
              final expanded = _expandedGroups.contains(groupIndex);
              final startIndex = cursor;
              if (expanded) cursor += items.length;
              return FAccordionItem(
                title: Text(group.label),
                child: FTileGroup(
                  children: [
                    for (final (i, item) in items.indexed)
                      _tile(item, expanded ? startIndex + i : -1),
                  ],
                ),
              );
            }(),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final hasContent = _query.isNotEmpty
        ? _searchResults.isNotEmpty
        : _recent.isNotEmpty || widget.groups.isNotEmpty;

    return CallbackShortcuts(
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
            Expanded(
              child: !hasContent
                  ? ListView(
                      controller: widget.scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: AppText(
                            widget.noResultsLabel,
                            variant: AppTextVariant.caption,
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      controller: widget.scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      children: _query.isNotEmpty
                          ? [
                              FTileGroup(
                                children: [
                                  for (final (index, item)
                                      in _searchResults.indexed)
                                    _tile(item, index),
                                ],
                              ),
                            ]
                          : _buildGroupedContent(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
