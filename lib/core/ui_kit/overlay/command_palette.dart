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

class _CommandSection {
  const _CommandSection(this.label, this.items);

  final String label;
  final List<AppCommandItem> items;
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

class _CommandPaletteContentState extends State<_CommandPaletteContent> {
  final _controller = TextEditingController();
  int _highlighted = 0;
  String _query = '';
  List<_CommandSection> _sections = const [];

  List<AppCommandItem> get _trackedItems => [
    for (final group in widget.groups)
      if (group.tracksRecent) ...group.items,
  ];

  List<AppCommandItem> get _visible => [
    for (final section in _sections) ...section.items,
  ];

  @override
  void initState() {
    super.initState();
    _applyQuery('');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applyQuery(String query) {
    _query = query.trim();
    _sections = _query.isEmpty ? _idleSections() : _searchSections();
  }

  List<_CommandSection> _idleSections() {
    final byLabel = {for (final item in _trackedItems) item.label: item};
    final recent = [
      for (final label in AppCommandPalette._recentLabels) ?byLabel[label],
    ];
    final recentLabels = recent.map((item) => item.label).toSet();
    return [
      _CommandSection(widget.recentLabel, recent),
      for (final group in widget.groups)
        if (group.showsWhenIdle)
          _CommandSection(group.label, [
            for (final item in group.items)
              if (!group.tracksRecent || !recentLabels.contains(item.label))
                item,
          ]),
    ].where((section) => section.items.isNotEmpty).toList();
  }

  List<_CommandSection> _searchSections() {
    final lower = _query.toLowerCase();
    return [
      for (final group in widget.groups)
        if (group.showsInSearch)
          () {
            final items = group.filtered(lower).items;
            return _CommandSection('${group.label} · ${items.length}', items);
          }(),
    ].where((section) => section.items.isNotEmpty).toList();
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

  List<Widget> _buildSections() {
    var cursor = 0;
    final searching = _query.isNotEmpty;

    return [
      for (final section in _sections)
        () {
          final start = cursor;
          cursor += section.items.length;
          return AppListGroup(
            label: section.label,
            children: [
              for (final (i, item) in section.items.indexed)
                _CommandRow(
                  item: item,
                  match: searching ? _query : null,
                  highlighted: searching && start + i == _highlighted,
                  onTap: () => _select(item),
                ),
            ],
          );
        }(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final noResultsAction = widget.noResultsAction;

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
          Expanded(
            child: _sections.isEmpty
                ? ListView(
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
                  )
                : ListView(
                    controller: widget.scrollController,
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
                    ),
                    children: [
                      for (final section in _buildSections()) ...[
                        section,
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ],
                  ),
          ),
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
