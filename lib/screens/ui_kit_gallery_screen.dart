import 'package:flutter/widgets.dart';

import '../core/ui_kit/ui_kit.dart';

/// A living catalogue of every component in `core/ui_kit`, grouped by the
/// same categories the kit's folders use.
class UiKitGalleryScreen extends StatelessWidget {
  const UiKitGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) => AppScrollArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppHeader.topInset(context) + AppSpacing.lg,
        AppSpacing.lg,
        AppBottomNav.bottomInset(context) + AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText('UI Kit', variant: AppTextVariant.display),
          const AppGap.sm(),
          const AppText(
            'Every component currently in core/ui_kit, in one place.',
            variant: AppTextVariant.caption,
          ),
          const AppGap.lg(),
          const _Section(title: 'Typography', child: _TypographySection()),
          const AppGap.lg(),
          _Section(title: 'Tokens', child: _TokensSection()),
          const AppGap.lg(),
          const _Section(title: 'Controls', child: _ControlsSection()),
          const AppGap.lg(),
          const _Section(title: 'Data display', child: _DataDisplaySection()),
          const AppGap.lg(),
          const _Section(title: 'Feedback', child: _FeedbackSection()),
          const AppGap.lg(),
          const _Section(title: 'Overlay', child: _OverlaySection()),
          const AppGap.lg(),
          const _Section(title: 'Navigation', child: _NavigationSection()),
          const AppGap.lg(),
          const _Section(title: 'Layout', child: _LayoutSection()),
          const AppGap.lg(),
          _Section(title: 'Primitives', child: _PrimitivesSection()),
          const AppGap.xl(),
        ],
      ),
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppText(title, variant: AppTextVariant.title),
      const AppGap.sm(),
      AppCard(child: child),
    ],
  );
}

class _TypographySection extends StatelessWidget {
  const _TypographySection();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: AppSpacing.sm,
    children: [
      AppText('Display', variant: AppTextVariant.display),
      AppText('Title', variant: AppTextVariant.title),
      AppText('Body', variant: AppTextVariant.body),
      AppText('Caption', variant: AppTextVariant.caption),
    ],
  );
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    spacing: AppSpacing.xs,
    children: [
      DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: AppRadius.of(context).sm,
          border: AppBorders.all(context),
        ),
        child: const SizedBox(width: 48, height: 48),
      ),
      AppText(label, variant: AppTextVariant.caption),
    ],
  );
}

class _TokensSection extends StatelessWidget {
  const _TokensSection();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: AppSpacing.md,
    children: [
      const AppText('Colors (AppColors)', variant: AppTextVariant.caption),
      const AppRow(
        children: [
          _Swatch(color: AppColors.graphite, label: 'graphite'),
          _Swatch(color: AppColors.silver, label: 'silver'),
        ],
      ),
      const AppText('Spacing (AppSpacing)', variant: AppTextVariant.caption),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.xs,
        children: [
          for (final (label, value) in const [
            ('xs', AppSpacing.xs),
            ('sm', AppSpacing.sm),
            ('md', AppSpacing.md),
            ('lg', AppSpacing.lg),
            ('xl', AppSpacing.xl),
          ])
            AppRow(
              children: [
                SizedBox(
                  width: 28,
                  child: AppText(label, variant: AppTextVariant.caption),
                ),
                Container(width: value, height: 8, color: AppColors.silver),
              ],
            ),
        ],
      ),
      const AppText('Radius (AppRadius)', variant: AppTextVariant.caption),
      AppRow(
        children: [
          for (final (label, radius) in [
            ('sm', AppRadius.of(context).sm),
            ('md', AppRadius.of(context).md),
            ('lg', AppRadius.of(context).lg),
            ('pill', AppRadius.of(context).pill),
          ])
            Column(
              spacing: AppSpacing.xs,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: AppBorders.all(context),
                    borderRadius: radius,
                  ),
                  child: const SizedBox(width: 40, height: 40),
                ),
                AppText(label, variant: AppTextVariant.caption),
              ],
            ),
        ],
      ),
      const AppText(
        'Typography (AppTypography)',
        variant: AppTextVariant.caption,
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.xs,
        children: [
          for (final (label, style) in [
            ('display.xl2', AppTypography.of(context).display.xl2),
            ('display.lg', AppTypography.of(context).display.lg),
            ('body.md', AppTypography.of(context).body.md),
            ('body.sm', AppTypography.of(context).body.sm),
            ('body.xs3', AppTypography.of(context).body.xs3),
          ])
            Text(label, style: style),
        ],
      ),
    ],
  );
}

class _ControlsSection extends StatefulWidget {
  const _ControlsSection();

  @override
  State<_ControlsSection> createState() => _ControlsSectionState();
}

class _ControlsSectionState extends State<_ControlsSection> {
  bool _checked = false;
  bool _switched = true;
  double _sliderValue = 0.4;
  String _format = 'pdf';

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: AppSpacing.md,
    children: [
      const AppText('AppButton', variant: AppTextVariant.caption),
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final variant in AppButtonVariant.values)
            AppButton(
              variant: variant,
              onPressed: () {},
              child: Text(variant.name),
            ),
        ],
      ),
      const AppText('AppCheckbox', variant: AppTextVariant.caption),
      AppCheckbox(
        value: _checked,
        onChanged: (value) => setState(() => _checked = value),
        label: 'Example checkbox',
      ),
      const AppText('AppInput', variant: AppTextVariant.caption),
      const AppInput(label: 'Document title', hint: 'Untitled document'),
      const AppText('AppSelect', variant: AppTextVariant.caption),
      AppSelect<String>(
        label: 'Page size',
        hint: 'Choose a size',
        items: const {'A4': 'a4', 'Letter': 'letter', 'Legal': 'legal'},
        onChanged: (value) {},
      ),
      const AppText('AppSwitch', variant: AppTextVariant.caption),
      AppSwitch(
        value: _switched,
        onChanged: (value) => setState(() => _switched = value),
        label: 'Auto-save',
      ),
      const AppText('AppSlider', variant: AppTextVariant.caption),
      AppSlider(
        value: _sliderValue,
        onChanged: (value) => setState(() => _sliderValue = value),
      ),
      const AppText('AppLabel', variant: AppTextVariant.caption),
      AppLabel(
        label: 'Zoom',
        description: 'Applies to the current document only.',
        child: AppSlider(
          value: _sliderValue,
          onChanged: (value) => setState(() => _sliderValue = value),
        ),
      ),
      const AppText('AppDateTimePicker', variant: AppTextVariant.caption),
      const SizedBox(height: 160, child: AppDateTimePicker()),
      const AppText('AppUpload', variant: AppTextVariant.caption),
      AppUpload(
        allowedExtensions: const ['pdf', 'docx', 'png'],
        onChanged: (files) {},
      ),
      const AppText('AppRadioGroup (classic)', variant: AppTextVariant.caption),
      AppRadioGroup<String>(
        value: _format,
        onChanged: (value) => setState(() => _format = value),
        options: const [
          AppRadioOption(value: 'pdf', label: 'PDF'),
          AppRadioOption(value: 'docx', label: 'DOCX'),
          AppRadioOption(value: 'djvu', label: 'DjVu'),
        ],
      ),
      const AppText('AppRadioGroup (card)', variant: AppTextVariant.caption),
      AppRadioGroup<String>(
        variant: AppRadioVariant.card,
        value: _format,
        onChanged: (value) => setState(() => _format = value),
        options: const [
          AppRadioOption(value: 'pdf', label: 'PDF'),
          AppRadioOption(value: 'docx', label: 'DOCX'),
          AppRadioOption(value: 'djvu', label: 'DjVu'),
        ],
      ),
      const AppText('AppOtpField', variant: AppTextVariant.caption),
      AppOtpField(length: 4, onCompleted: (code) {}),
    ],
  );
}

class _DataDisplaySection extends StatefulWidget {
  const _DataDisplaySection();

  @override
  State<_DataDisplaySection> createState() => _DataDisplaySectionState();
}

class _DataDisplaySectionState extends State<_DataDisplaySection> {
  final List<String> _dismissibleItems = [
    'Invoice.pdf',
    'Report.docx',
    'Scan.djvu',
  ];
  final List<String> _reorderableItems = [
    'First chapter',
    'Second chapter',
    'Third chapter',
  ];
  final List<String> _tagItems = ['All', 'PDF', 'DOCX', 'DjVu'];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: AppSpacing.md,
    children: [
      const AppText('AppList / AppListItem', variant: AppTextVariant.caption),
      AppList(
        items: [
          AppListItem(
            title: 'Item one',
            subtitle: 'With a subtitle',
            leading: AppIcons.file,
            onTap: () {},
          ),
          AppListItem(title: 'Item two', leading: AppIcons.file, onTap: () {}),
        ],
      ),
      const AppText('AppBadge', variant: AppTextVariant.caption),
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final variant in AppBadgeVariant.values)
            AppBadge(variant: variant, child: Text(variant.name)),
        ],
      ),
      const AppText('AppTag', variant: AppTextVariant.caption),
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final item in _tagItems)
            AppTag(
              label: Text(item),
              onRemove: () => setState(() => _tagItems.remove(item)),
            ),
        ],
      ),
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final variant in AppTagVariant.values)
            AppTag(label: Text(variant.name), variant: variant),
        ],
      ),
      const AppText('AppCollapsible', variant: AppTextVariant.caption),
      const AppCollapsible(
        title: 'What file formats are supported?',
        child: AppText('PDF, DOCX and DjVu.', variant: AppTextVariant.caption),
      ),
      const AppText('AppAvatar', variant: AppTextVariant.caption),
      const AppRow(
        children: [
          AppAvatar(initials: 'FR'),
          AppAvatar(initials: 'JD', size: 56),
        ],
      ),
      const AppText('AppAccordion', variant: AppTextVariant.caption),
      AppAccordion(
        items: [
          AppAccordionItem(
            title: 'What file formats are supported?',
            child: const AppText(
              'PDF, DOCX and DjVu.',
              variant: AppTextVariant.caption,
            ),
          ),
          AppAccordionItem(
            title: 'Can I edit scanned documents?',
            child: const AppText(
              'Only PDF and DjVu, via OCR.',
              variant: AppTextVariant.caption,
            ),
          ),
        ],
      ),
      const AppText('AppLineCalendar', variant: AppTextVariant.caption),
      SizedBox(height: 88, child: AppLineCalendar(onChanged: (date) {})),
      const AppText(
        'AppDismissible (swipe to delete)',
        variant: AppTextVariant.caption,
      ),
      Column(
        children: [
          for (final item in _dismissibleItems)
            AppDismissible(
              itemKey: ValueKey(item),
              onDismissed: () => setState(() => _dismissibleItems.remove(item)),
              child: AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: AppText(item),
              ),
            ),
        ],
      ),
      const AppText(
        'AppReorderableList (drag handle)',
        variant: AppTextVariant.caption,
      ),
      SizedBox(
        height: 160,
        child: AppReorderableList<String>(
          items: _reorderableItems,
          itemKey: (item) => ValueKey(item),
          onReorder: (oldIndex, newIndex) => setState(() {
            final item = _reorderableItems.removeAt(oldIndex);
            _reorderableItems.insert(newIndex, item);
          }),
          itemBuilder: (context, item, index) => AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: AppText(item),
          ),
        ),
      ),
    ],
  );
}

class _FeedbackSection extends StatelessWidget {
  const _FeedbackSection();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: AppSpacing.md,
    children: [
      const AppText('AppAlert', variant: AppTextVariant.caption),
      const AppAlert(
        title: Text('Heads up'),
        subtitle: Text('This is a primary alert.'),
      ),
      const AppGap.xs(),
      const AppAlert(
        title: Text('Something went wrong'),
        subtitle: Text('This is a destructive alert.'),
        variant: AppAlertVariant.destructive,
      ),
      const AppText('AppSpinner', variant: AppTextVariant.caption),
      AppRow(
        children: [
          for (final size in AppSpinnerSize.values) AppSpinner(size: size),
        ],
      ),
      const AppText('AppSkeleton', variant: AppTextVariant.caption),
      const AppRow(
        children: [
          AppSkeleton.circle(size: 40),
          AppSkeleton(width: 40, height: 40),
          AppSkeleton(width: 120),
        ],
      ),
      const AppGap.sm(),
      const AppSkeletonText(),
      const AppText('AppProgress', variant: AppTextVariant.caption),
      const AppProgress(value: 0.6),
      const AppGap.xs(),
      const AppProgress(),
    ],
  );
}

class _OverlaySection extends StatelessWidget {
  const _OverlaySection();

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.sm,
    children: [
      AppTooltip(
        message:
            'This button is wrapped in AppTooltip — hover or long-press it',
        child: AppButton(
          variant: AppButtonVariant.ghost,
          onPressed: () {},
          child: const Text('Hover / long-press me'),
        ),
      ),
      AppPopover(
        popoverBuilder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: AppText('A popover, aligned to its child.'),
        ),
        child: const AppButton(
          variant: AppButtonVariant.outline,
          onPressed: null,
          child: Text('Show popover'),
        ),
      ),
      AppPopoverMenu(
        items: [
          AppCommandItem(
            label: 'Rename',
            icon: AppIcons.pencil,
            onSelect: () {},
          ),
          AppCommandItem(
            label: 'Duplicate',
            icon: AppIcons.copy,
            onSelect: () {},
          ),
          AppCommandItem(
            label: 'Delete',
            icon: AppIcons.trash2,
            onSelect: () {},
          ),
        ],
        child: const AppButton(
          variant: AppButtonVariant.outline,
          onPressed: null,
          child: Text('Show popover menu'),
        ),
      ),
      AppContextMenu(
        items: [
          AppCommandItem(
            label: 'Rename',
            icon: AppIcons.pencil,
            onSelect: () {},
          ),
          AppCommandItem(
            label: 'Duplicate',
            icon: AppIcons.copy,
            onSelect: () {},
          ),
          AppCommandItem(
            label: 'Delete',
            icon: AppIcons.trash2,
            onSelect: () {},
          ),
        ],
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: AppBorders.all(context),
            borderRadius: AppRadius.of(context).md,
          ),
          child: const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: AppText('Long-press me'),
          ),
        ),
      ),
      AppButton(
        variant: AppButtonVariant.outline,
        onPressed: () => AppDialog.show(
          context: context,
          title: const Text('AppDialog'),
          body: const Text('A centered modal dialog.'),
          actions: [
            AppButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
        child: const Text('Show dialog'),
      ),
      AppButton(
        variant: AppButtonVariant.outline,
        onPressed: () => AppSheet.show(
          context: context,
          builder: (context, scrollController) => ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const AppText(
                'Drag the handle up to expand, or down past the halfway point to dismiss.',
              ),
              const AppGap.md(),
              AppButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
        child: const Text('Show sheet'),
      ),
      AppButton(
        variant: AppButtonVariant.outline,
        onPressed: () => AppSidePanel.show(
          context: context,
          builder: (context, controller) {
            return Column(
              children: [
                AppSidePanelHeader(title: 'Outline', onClose: controller.close),
                const AppSidePanelContent(
                  child: AppText(
                    'A side panel — 80% width, dims and blocks the rest of the app while shown.',
                  ),
                ),
                AppSidePanelFooter(
                  children: [
                    AppButton(
                      onPressed: controller.close,
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        child: const Text('Show side panel'),
      ),
      AppButton(
        variant: AppButtonVariant.outline,
        onPressed: () => AppCommandPalette.show(
          context: context,
          groups: [
            AppCommandGroup(
              label: 'Files',
              items: [
                AppCommandItem(
                  label: 'Open document…',
                  icon: AppIcons.file,
                  onSelect: () {},
                ),
                AppCommandItem(
                  label: 'New folder',
                  icon: AppIcons.folderPlus,
                  onSelect: () {},
                ),
                AppCommandItem(
                  label: 'Export as PDF',
                  icon: AppIcons.download,
                  onSelect: () {},
                ),
              ],
            ),
            AppCommandGroup(
              label: 'App',
              items: [
                AppCommandItem(
                  label: 'Toggle dark mode',
                  icon: AppIcons.moon,
                  onSelect: () {},
                ),
                AppCommandItem(
                  label: 'Settings',
                  icon: AppIcons.settings,
                  onSelect: () {},
                ),
              ],
            ),
          ],
        ),
        child: const Text('Show command palette'),
      ),
      AppButton(
        variant: AppButtonVariant.outline,
        onPressed: () => AppToast.show(
          context: context,
          title: const Text('AppToast'),
          description: const Text('A transient status message.'),
        ),
        child: const Text('Show toast'),
      ),
    ],
  );
}

class _NavigationSection extends StatelessWidget {
  const _NavigationSection();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: AppSpacing.md,
    children: [
      const AppText('AppHeader', variant: AppTextVariant.caption),
      DecoratedBox(
        decoration: BoxDecoration(
          border: AppBorders.all(context),
          borderRadius: AppRadius.of(context).md,
        ),
        child: AppHeader(
          title: 'ChatGPT',
          onMenuTap: () {},
          actionLabel: 'Sign in',
          onActionTap: () {},
        ),
      ),
      const AppText(
        'AppBottomNav is already this app\'s bottom navigation bar.',
        variant: AppTextVariant.caption,
      ),
      const AppText('AppTabs', variant: AppTextVariant.caption),
      SizedBox(
        height: 160,
        child: AppTabs(
          tabs: [
            AppTab(
              label: 'Pages',
              child: const AppCenter(child: Text('Pages tab content')),
            ),
            AppTab(
              label: 'Outline',
              child: const AppCenter(child: Text('Outline tab content')),
            ),
            AppTab(
              label: 'Bookmarks',
              child: const AppCenter(child: Text('Bookmarks tab content')),
            ),
          ],
        ),
      ),
      const AppText('AppPagination', variant: AppTextVariant.caption),
      AppPagination(pageCount: 10, onChanged: (page) {}),
    ],
  );
}

class _LayoutSection extends StatelessWidget {
  const _LayoutSection();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: AppSpacing.md,
    children: [
      const AppText(
        "AppScaffold is already this app's page shell (header/footer/body).",
        variant: AppTextVariant.caption,
      ),
      const AppText('AppDivider', variant: AppTextVariant.caption),
      const Text('Above'),
      const AppDivider(),
      const Text('Below'),
      const AppGap.sm(),
      const AppText('AppResizable', variant: AppTextVariant.caption),
      SizedBox(
        height: 120,
        child: AppResizable(
          axis: Axis.horizontal,
          regions: [
            AppResizableRegion(
              flex: 1,
              child: const AppCenter(child: Text('Outline')),
            ),
            AppResizableRegion(
              flex: 2,
              child: const AppCenter(child: Text('Document')),
            ),
          ],
        ),
      ),
    ],
  );
}

class _PrimitivesSection extends StatelessWidget {
  const _PrimitivesSection();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: AppSpacing.md,
    children: [
      const AppText(
        'AppScrollArea wraps this whole screen.',
        variant: AppTextVariant.caption,
      ),
      const AppText(
        'AppRow (default spacing)',
        variant: AppTextVariant.caption,
      ),
      const AppRow(
        children: [Icon(AppIcons.check), Text('Row with default spacing')],
      ),
      const AppText(
        'AppStack (centered by default)',
        variant: AppTextVariant.caption,
      ),
      SizedBox(
        height: 60,
        child: AppStack(
          children: [
            Container(color: AppColors.silver, width: 60, height: 60),
            const Icon(AppIcons.star),
          ],
        ),
      ),
      const AppText(
        'AppCenter (with padding)',
        variant: AppTextVariant.caption,
      ),
      DecoratedBox(
        decoration: BoxDecoration(border: AppBorders.all(context)),
        child: const AppCenter(padding: AppSpacing.md, child: Text('Centered')),
      ),
      const AppText('AppGrid', variant: AppTextVariant.caption),
      AppGrid(
        children: [
          for (final label in ['A', 'B', 'C'])
            DecoratedBox(
              decoration: BoxDecoration(
                border: AppBorders.all(context),
                borderRadius: AppRadius.of(context).sm,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: AppText(label),
              ),
            ),
        ],
      ),
      const AppText(
        'AppZoomable (pinch to zoom)',
        variant: AppTextVariant.caption,
      ),
      SizedBox(
        height: 140,
        child: ClipRRect(
          borderRadius: AppRadius.of(context).sm,
          child: AppZoomable(
            child: DecoratedBox(
              decoration: BoxDecoration(color: AppColors.silver),
              child: Center(
                child: AppText('Page 1', color: AppColors.graphite),
              ),
            ),
          ),
        ),
      ),
      const AppText(
        'AppPageView (swipe between pages)',
        variant: AppTextVariant.caption,
      ),
      SizedBox(
        height: 100,
        child: AppPageView(
          children: [
            for (final label in ['Page A', 'Page B', 'Page C'])
              DecoratedBox(
                decoration: BoxDecoration(
                  border: AppBorders.all(context),
                  borderRadius: AppRadius.of(context).sm,
                ),
                child: AppCenter(child: AppText(label)),
              ),
          ],
        ),
      ),
      const AppText('AppPullToRefresh', variant: AppTextVariant.caption),
      SizedBox(
        height: 140,
        child: AppPullToRefresh(
          onRefresh: () => Future.delayed(const Duration(seconds: 1)),
          child: AppList(
            items: [
              for (var i = 1; i <= 3; i++)
                AppListItem(title: 'Item $i', leading: AppIcons.file),
            ],
          ),
        ),
      ),
    ],
  );
}
