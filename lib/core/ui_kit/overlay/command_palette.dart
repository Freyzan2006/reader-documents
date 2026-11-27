import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../controls/button.dart';
import '../controls/search_field.dart';
import '../data_display/empty_state.dart';
import '../data_display/list.dart';
import '../theme/app_tokens.dart';
import '../tokens/app_icons.dart';
import '../tokens/app_radius.dart';
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
    this.value,
    this.keywords = const [],
  });

  final String label;
  final IconData? icon;
  final Widget? leading;
  final String? subtitle;
  final String? value;
  final List<String> keywords;
  final VoidCallback onSelect;

  bool matches(String lowerQuery) =>
      label.toLowerCase().contains(lowerQuery) ||
      keywords.any((keyword) => keyword.toLowerCase().contains(lowerQuery));

  Widget? get prefix => leading ?? (icon == null ? null : Icon(icon, size: 20));
}

enum AppCommandGroupMode { always, idle, search }

class AppCommandGroup {
  const AppCommandGroup({
    required this.label,
    this.items = const [],
    this.mode = AppCommandGroupMode.always,
  }) : search = null,
       searchLimit = 30;

  const AppCommandGroup.search({
    required this.label,
    required List<AppCommandItem> Function(String query, int limit) this.search,
    this.searchLimit = 30,
  }) : items = const [],
       mode = AppCommandGroupMode.search;

  final String label;
  final List<AppCommandItem> items;
  final AppCommandGroupMode mode;
  final List<AppCommandItem> Function(String query, int limit)? search;
  final int searchLimit;

  bool get isLazy => search != null;
  bool get showsWhenIdle => mode != AppCommandGroupMode.search;
  bool get showsInSearch => mode != AppCommandGroupMode.idle;
  bool get tracksRecent => mode == AppCommandGroupMode.always && !isLazy;

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
              AppListGroup(
                children: [
                  for (final item in items)
                    AppListRow(
                      title: item.label,
                      prefix: item.prefix,
                      onTap: () {
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
    String? clearLabel,
    AppCommandItem? noResultsAction,
    AppBarrierVariant? barrierVariant,
  }) => AppSheet.show<void>(
    context: context,
    barrierVariant: barrierVariant,
    initialSize: 0.92,
    minSize: 0.5,
    maxSize: 0.92,
    builder: (context, scrollController) => _CommandPaletteContent(
      groups: groups,
      hint: hint,
      recentLabel: recentLabel,
      noResultsLabel: noResultsLabel,
      clearLabel: clearLabel,
      noResultsAction: noResultsAction,
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
    this.clearLabel,
    this.noResultsAction,
  });

  final List<AppCommandGroup> groups;
  final String hint;
  final String recentLabel;
  final String noResultsLabel;
  final String? clearLabel;
  final AppCommandItem? noResultsAction;
  final ScrollController scrollController;

  @override
  State<_CommandPaletteContent> createState() => _CommandPaletteContentState();
}

class _CommandSection {
  const _CommandSection(this.label, this.items);

  final String label;
  final List<AppCommandItem> items;
}

class _CommandPaletteContentState extends State<_CommandPaletteContent> {
  final _controller = TextEditingController();
  String _query = '';
  int _highlighted = 0;
  List<_CommandSection> _sections = const [];
  List<AppCommandItem> _visible = const [];

  bool get _searching => _query.isNotEmpty;

  List<AppCommandItem> get _trackedItems => [
    for (final group in widget.groups)
      if (group.tracksRecent) ...group.items,
  ];

  @override
  void initState() {
    super.initState();
    _rebuild();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) => setState(() {
    _query = query.trim();
    _highlighted = 0;
    _rebuild();
  });

  void _rebuild() {
    _sections = _searching ? _searchSections() : _idleSections();
    _visible = [for (final section in _sections) ...section.items];
  }

  List<_CommandSection> _idleSections() {
    final tracked = _trackedItems;
    final recent = _recent(tracked);
    final recentLabels = recent.map((item) => item.label).toSet();
    return [
      _CommandSection(widget.recentLabel, recent),
      for (final group in widget.groups)
        if (group.showsWhenIdle)
          _CommandSection(group.label, _idleItems(group, recentLabels)),
    ].where((section) => section.items.isNotEmpty).toList();
  }

  List<AppCommandItem> _recent(List<AppCommandItem> tracked) {
    final byLabel = {for (final item in tracked) item.label: item};
    return [
      for (final label in AppCommandPalette._recentLabels) ?byLabel[label],
    ];
  }

  List<AppCommandItem> _idleItems(
    AppCommandGroup group,
    Set<String> recentLabels,
  ) => [
    for (final item in group.items)
      if (!group.tracksRecent || !recentLabels.contains(item.label)) item,
  ];

  List<_CommandSection> _searchSections() {
    final lower = _query.toLowerCase();
    return [
      for (final group in widget.groups)
        if (group.showsInSearch) _searchSection(group, lower),
    ].where((section) => section.items.isNotEmpty).toList();
  }

  _CommandSection _searchSection(AppCommandGroup group, String lower) {
    final items = group.isLazy
        ? group.search!(_query, group.searchLimit)
        : group.filtered(lower).items;
    final count = group.isLazy && items.length == group.searchLimit
        ? '${items.length}+'
        : '${items.length}';
    return _CommandSection('${group.label} · $count', items);
  }

  void _move(int delta) {
    if (_visible.isEmpty) return;
    setState(() {
      _highlighted = (_highlighted + delta + _visible.length) % _visible.length;
    });
  }

  void _selectHighlighted() {
    if (_visible.isNotEmpty) _select(_visible[_highlighted]);
  }

  void _select(AppCommandItem item) {
    if (_trackedItems.contains(item)) {
      AppCommandPalette._recordRecent(item.label);
    }
    Navigator.of(context).pop();
    item.onSelect();
  }

  Widget _buildResults(BuildContext context) {
    final noResultsAction = widget.noResultsAction;
    if (_sections.isEmpty) {
      return ListView(
        controller: widget.scrollController,
        children: [
          AppEmptyState(
            icon: AppIcons.search,
            message: widget.noResultsLabel,
            action: noResultsAction == null
                ? null
                : AppButton(
                    variant: AppButtonVariant.outline,
                    mainAxisSize: MainAxisSize.min,
                    prefix: noResultsAction.prefix,
                    onPressed: () => _select(noResultsAction),
                    child: Text(noResultsAction.label),
                  ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: widget.scrollController,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      itemCount: _sections.length,
      itemBuilder: (context, index) => _buildSection(index),
    );
  }

  Widget _buildSection(int index) {
    var start = 0;
    for (var i = 0; i < index; i++) {
      start += _sections[i].items.length;
    }
    final section = _sections[index];
    return Padding(
      padding: EdgeInsets.only(
        bottom: index == _sections.length - 1 ? 0 : AppSpacing.lg,
      ),
      child: AppListGroup(
        label: section.label,
        children: [
          for (final (i, item) in section.items.indexed)
            _CommandRow(
              item: item,
              match: _searching ? _query : null,
              highlighted: _searching && start + i == _highlighted,
              onTap: () => _select(item),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowDown): () => _move(1),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () => _move(-1),
        const SingleActivator(LogicalKeyboardKey.enter): _selectHighlighted,
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).pop(),
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: AppSearchField(
              controller: _controller,
              hint: widget.hint,
              clearLabel: widget.clearLabel,
              autofocus: true,
              onChanged: _onQueryChanged,
              onSubmitted: (_) => _selectHighlighted(),
            ),
          ),
          Expanded(child: _buildResults(context)),
        ],
      ),
    );
  }
}

class _CommandRow extends StatelessWidget {
  const _CommandRow({
    required this.item,
    required this.highlighted,
    required this.onTap,
    this.match,
  });

  final AppCommandItem item;
  final bool highlighted;
  final String? match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppListRow(
    title: item.label,
    subtitle: item.subtitle,
    value: highlighted ? null : item.value,
    prefix: item.prefix,
    match: match,
    highlighted: highlighted,
    trailing: highlighted ? const _EnterHint() : null,
    onTap: onTap,
  );
}

class _EnterHint extends StatelessWidget {
  const _EnterHint();

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    return ExcludeSemantics(
      child: Container(
        height: 20,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: AppRadii.xs,
          border: Border.all(color: palette.ruleStrong),
        ),
        child: Icon(AppIcons.cornerDownLeft, size: 12, color: palette.ink3),
      ),
    );
  }
}
