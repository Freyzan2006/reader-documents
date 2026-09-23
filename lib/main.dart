import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'core/ui_kit/ui_kit.dart';

void main() {
  runApp(const ReaderDocumentsApp());
}

class ReaderDocumentsApp extends StatefulWidget {
  const ReaderDocumentsApp({super.key});

  @override
  State<ReaderDocumentsApp> createState() => _ReaderDocumentsAppState();
}

class _ReaderDocumentsAppState extends State<ReaderDocumentsApp> {
  Brightness _brightness = Brightness.light;

  void _toggleBrightness() {
    setState(() {
      _brightness = _brightness == Brightness.light ? Brightness.dark : Brightness.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(_brightness);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reader Documents',
      localizationsDelegates: FLocalizations.localizationsDelegates,
      supportedLocales: FLocalizations.supportedLocales,
      builder: (context, child) => FTheme(data: theme, child: child!),
      home: HomePage(brightness: _brightness, onToggleBrightness: _toggleBrightness),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({required this.brightness, required this.onToggleBrightness, super.key});

  final Brightness brightness;
  final VoidCallback onToggleBrightness;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(
        title: const Text('Reader Documents'),
        suffixes: [
          FHeaderAction(
            icon: Icon(widget.brightness == Brightness.dark ? FLucideIcons.sun : FLucideIcons.moon),
            onPress: widget.onToggleBrightness,
          ),
        ],
      ),
      footer: AppBottomNav(
        currentIndex: _navIndex,
        onChanged: (index) => setState(() => _navIndex = index),
        items: const [
          AppBottomNavItem(icon: FLucideIcons.house, label: 'Home'),
          AppBottomNavItem(icon: FLucideIcons.search, label: 'Search'),
          AppBottomNavItem(icon: FLucideIcons.settings, label: 'Settings'),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Themed with Forui', style: context.theme.typography.body.lg),
                const AppGap.sm(),
                const Text('Buttons below use the brand color from AppTheme, not Forui defaults.'),
                const AppGap.lg(),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    AppButton(onPressed: () {}, child: const Text('Primary')),
                    AppButton(variant: AppButtonVariant.secondary, onPressed: () {}, child: const Text('Secondary')),
                    AppButton(variant: AppButtonVariant.outline, onPressed: () {}, child: const Text('Outline')),
                    AppButton(variant: AppButtonVariant.destructive, onPressed: () {}, child: const Text('Delete')),
                  ],
                ),
              ],
            ),
          ),
          const AppGap.lg(),
          AppCard(child: _AutoSyncRow()),
          const AppGap.lg(),
          Text('ui_kit primitives: AppGrid', style: context.theme.typography.body.lg),
          const AppGap.sm(),
          AppGrid(
            children: [
              for (final label in ['Recent', 'Favorites', 'Shared', 'Trash'])
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: AppBorders.all(context),
                    borderRadius: AppRadius.of(context).md,
                  ),
                  child: Padding(padding: const EdgeInsets.all(AppSpacing.md), child: Text(label)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AutoSyncRow extends StatefulWidget {
  @override
  State<_AutoSyncRow> createState() => _AutoSyncRowState();
}

class _AutoSyncRowState extends State<_AutoSyncRow> {
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Auto-sync annotations'),
        FSwitch(value: _enabled, onChange: (value) => setState(() => _enabled = value)),
      ],
    );
  }
}
