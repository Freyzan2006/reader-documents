import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../controls/input.dart';
import '../data_display/text.dart';
import '../layout/divider.dart';
import '../tokens/app_spacing.dart';
import 'barrier.dart';
import 'rotation.dart';
import 'sheet.dart';
import 'side_panel.dart';

class AppCommandItem {
  const AppCommandItem({
    required this.label,
    required this.onSelect,
    this.icon,
    this.leading,
    this.subtitle,
    this.keywords = const [],
  });

  final String label;
  final IconData? icon;
  final Widget? leading;
  final String? subtitle;
  final List<String> keywords;
  final VoidCallback onSelect;

  bool matches(String lowerQuery) =>
      label.toLowerCase().contains(lowerQuery) ||
      keywords.any((keyword) => keyword.toLowerCase().contains(lowerQuery));

  Widget? get prefix => leading ?? (icon == null ? null : Icon(icon));
}

enum AppCommandGroupMode { always, idle, search }

class AppCommandGroup {
  const AppCommandGroup({
    required this.label,
    required this.items,
    this.mode = AppCommandGroupMode.always,
  });

  final String label;
  final List<AppCommandItem> items;
  final AppCommandGroupMode mode;

  bool get showsWhenIdle => mode != AppCommandGroupMode.search;
  bool get showsInSearch => mode != AppCommandGroupMode.idle;
  bool get tracksRecent => mode == AppCommandGroupMode.always;

  AppCommandGroup filtered(String lowerQuery) => AppCommandGroup(
    label: label,
    mode: mode,
    items: items.where((item) => item.matches(lowerQuery)).toList(),
  );
}

/// A plain list of [AppCommandItem]s shown as a side panel instead of an
/// anchored popover — for triggers whose on-screen position/transform an
/// anchored popover can't reliably read (e.g. a button under an ancestor
/// `RotatedBox`), since a panel is always positioned against the true
/// screen edge, not the trigger. [side] defaults to [AppRotation.bottomEdge],
/// so a caller under a rotated surface gets the right edge and counter-
/// rotation for free without passing anything.
abstract final class AppCommandSidePanel {
  static AppSidePanelController show({
    required BuildContext context,
    required List<AppCommandItem> items,
    AppEdge? side,
    double panelFraction = 0.6,
    AppBarrierVariant? barrierVariant,
  }) {
    // Resolved from the caller's context, not the panel's own builder
    // context below — the panel renders into the app's root `Overlay`, which
    // sits outside whatever ancestor `AppRotation` the caller is under.
    final quarterTurns = AppRotation.of(context);
    final resolvedSide = side ?? AppRotation.bottomEdge(context);

    return AppSidePanel.show(
      context: context,
      side: resolvedSide,
      panelFraction: panelFraction,
      barrierVariant: barrierVariant,
      builder: (context, controller) => RotatedBox(
        quarterTurns: quarterTurns,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              FTileGroup(
                children: [
                  for (final item in items)
                    FTile(
                      title: Text(item.label),
                      prefix: item.prefix,
                      onPress: () {
                        controller.close();
                        item.onSelect();
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
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
    AppBarrierVariant? barrierVariant,
  }) => AppSheet.show<void>(
    context: context,
    barrierVariant: barrierVariant,
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
  late List<AppCommandGroup> _searchGroups;

  late final List<AppCommandGroup> _idleGroups = widget.groups
      .where((group) => group.showsWhenIdle && group.items.isNotEmpty)
      .toList();

  List<AppCommandItem> get _trackedItems => [
    for (final group in widget.groups)
      if (group.tracksRecent) ...group.items,
  ];

  @override
  void initState() {
    super.initState();
    _expandedGroups = {for (var i = 0; i < _idleGroups.length; i++) i};
    _applyQuery('');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applyQuery(String query) {
    _query = query.trim();
    if (_query.isEmpty) {
      final byLabel = {for (final item in _trackedItems) item.label: item};
      _recent = [
        for (final label in AppCommandPalette._recentLabels) ?byLabel[label],
      ];
      _searchGroups = const [];
    } else {
      _recent = const [];
      final lower = _query.toLowerCase();
      _searchGroups = [
        for (final group in widget.groups)
          if (group.showsInSearch) group.filtered(lower),
      ].where((group) => group.items.isNotEmpty).toList();
    }
  }

  List<AppCommandItem> _idleGroupItems(int groupIndex) {
    final group = _idleGroups[groupIndex];
    if (!group.tracksRecent) return group.items;
    final recentLabels = _recent.map((item) => item.label).toSet();
    return group.items
        .where((item) => !recentLabels.contains(item.label))
        .toList();
  }

  List<AppCommandItem> get _visible {
    if (_query.isNotEmpty) {
      return [for (final group in _searchGroups) ...group.items];
    }
    final visible = [..._recent];
    for (var i = 0; i < _idleGroups.length; i++) {
      if (_expandedGroups.contains(i)) visible.addAll(_idleGroupItems(i));
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
    if (_trackedItems.contains(item)) {
      AppCommandPalette._recordRecent(item.label);
    }
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
    title: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis),
    subtitle: item.subtitle == null ? null : Text(item.subtitle!),
    prefix: item.prefix,
    onPress: () => _select(item),
  );

  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(0, AppSpacing.sm, 0, AppSpacing.xs),
    child: AppText(label, variant: AppTextVariant.caption),
  );

  List<Widget> _buildSearchContent() {
    var cursor = 0;

    return [
      for (final group in _searchGroups) ...[
        _sectionLabel(group.label),
        () {
          final startIndex = cursor;
          cursor += group.items.length;
          return FTileGroup(
            children: [
              for (final (i, item) in group.items.indexed)
                _tile(item, startIndex + i),
            ],
          );
        }(),
      ],
    ];
  }

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
          for (final (groupIndex, group) in _idleGroups.indexed)
            () {
              final items = _idleGroupItems(groupIndex);
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
        ? _searchGroups.isNotEmpty
        : _recent.isNotEmpty || _idleGroups.isNotEmpty;

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
              child: ListView(
                controller: widget.scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                children: !hasContent
                    ? [
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: AppText(
                            widget.noResultsLabel,
                            variant: AppTextVariant.caption,
                          ),
                        ),
                      ]
                    : _query.isNotEmpty
                    ? _buildSearchContent()
                    : _buildGroupedContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
