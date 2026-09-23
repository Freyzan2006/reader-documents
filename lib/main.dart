import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'core/ui_kit/ui_kit.dart';
import 'screens/home_tab.dart';
import 'screens/search_tab.dart';
import 'screens/settings_tab.dart';
import 'screens/ui_kit_gallery_screen.dart';

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
      _brightness = _brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light;
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
      builder: (context, child) => FTheme(
        data: theme,
        child: FToaster(child: child!),
      ),
      home: HomePage(
        brightness: _brightness,
        onToggleBrightness: _toggleBrightness,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    required this.brightness,
    required this.onToggleBrightness,
    super.key,
  });

  final Brightness brightness;
  final VoidCallback onToggleBrightness;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 0;

  static const _tabs = [
    HomeTab(),
    SearchTab(),
    UiKitGalleryScreen(),
    SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: AppHeader(
        title: 'RD',
        onMenuTap: () => _openMenu(context),
        actionLabel: widget.brightness == Brightness.dark ? 'Dark' : 'Light',
        onActionTap: widget.onToggleBrightness,
      ),
      footer: AppBottomNav(
        currentIndex: _navIndex,
        onChanged: (index) => setState(() => _navIndex = index),
        items: const [
          AppBottomNavItem(icon: FLucideIcons.house, label: 'Home'),
          AppBottomNavItem(icon: FLucideIcons.search, label: 'Search'),
          AppBottomNavItem(icon: FLucideIcons.palette, label: 'UI Kit'),
          AppBottomNavItem(icon: FLucideIcons.settings, label: 'Settings'),
        ],
      ),
      child: IndexedStack(index: _navIndex, children: _tabs),
    );
  }

  void _openMenu(BuildContext context) {
    AppSidePanel.show(
      context: context,
      builder: (context, controller) => Column(
        children: [
          AppSidePanelHeader(title: 'Menu', onClose: controller.close),
          AppSidePanelContent(
            child: AppList(
              items: [
                AppListItem(
                  title: 'Home',
                  leading: FLucideIcons.house,
                  onTap: controller.close,
                ),
                AppListItem(
                  title: 'Search',
                  leading: FLucideIcons.search,
                  onTap: controller.close,
                ),
                AppListItem(
                  title: 'UI Kit',
                  leading: FLucideIcons.palette,
                  onTap: controller.close,
                ),
                AppListItem(
                  title: 'Settings',
                  leading: FLucideIcons.settings,
                  onTap: controller.close,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
