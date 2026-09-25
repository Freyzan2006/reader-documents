import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:reader_documents/features/documents/presentation/documents_screen.dart';
import 'package:reader_documents/features/documents/presentation/shared_pdf_intake.dart';
import 'package:reader_documents/features/settings/application/settings_providers.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';
import 'package:reader_documents/features/settings/presentation/settings_screen.dart';
import 'package:reader_documents/l10n/app_localizations.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'app_command_launcher.dart';
import 'core/localization/app_locale_resolver.dart';
import 'core/ui_kit/ui_kit.dart';
import 'screens/ui_kit_gallery_screen.dart';

void main() {
  runApp(const ProviderScope(child: ReaderDocumentsApp()));
}

class ReaderDocumentsApp extends ConsumerWidget {
  const ReaderDocumentsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value ?? AppSettings.defaults;
    final brightness = settings.resolveBrightness(
      MediaQuery.platformBrightnessOf(context),
    );
    final theme = AppTheme.of(brightness);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reader Documents',
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        ...FLocalizations.localizationsDelegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: settings.language.locale,
      localeResolutionCallback: (locale, supportedLocales) =>
          AppLocaleResolver.resolve(locale, supportedLocales),
      builder: (context, child) => FTheme(
        data: theme,
        child: FToaster(child: child!),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _navIndex = 0;
  late final StreamSubscription<List<SharedMediaFile>> _sharedPdfSubscription;

  static const _tabs = [
    DocumentsScreen(),
    UiKitGalleryScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _sharedPdfSubscription = SharedPdfIntake.listen(context, ref);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => SharedPdfIntake.checkInitial(context, ref),
    );
  }

  @override
  void dispose() {
    _sharedPdfSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      header: AppHeader(
        title: 'RD',
        onMenuTap: () => _openMenu(context, l10n),
        actionIcon: FLucideIcons.command,
        onActionTap: () => AppCommandLauncher.show(context, ref),
      ),
      footer: AppBottomNav(
        currentIndex: _navIndex,
        onChanged: (index) => setState(() => _navIndex = index),
        items: [
          AppBottomNavItem(icon: FLucideIcons.house, label: l10n.navHome),
          AppBottomNavItem(icon: FLucideIcons.palette, label: l10n.navUiKit),
          AppBottomNavItem(
            icon: FLucideIcons.settings,
            label: l10n.navSettings,
          ),
        ],
      ),
      child: IndexedStack(index: _navIndex, children: _tabs),
    );
  }

  void _openMenu(BuildContext context, AppLocalizations l10n) {
    AppSidePanel.show(
      context: context,
      builder: (context, controller) => Column(
        children: [
          AppSidePanelHeader(title: l10n.menuTitle, onClose: controller.close),
          AppSidePanelContent(
            child: AppList(
              items: [
                AppListItem(
                  title: l10n.navHome,
                  leading: FLucideIcons.house,
                  onTap: controller.close,
                ),
                AppListItem(
                  title: l10n.navUiKit,
                  leading: FLucideIcons.palette,
                  onTap: controller.close,
                ),
                AppListItem(
                  title: l10n.navSettings,
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
