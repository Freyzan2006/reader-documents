import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/dev/preview.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/presentation/documents_screen.dart';
import 'package:reader_documents/features/documents/presentation/home_screen.dart';
import 'package:reader_documents/features/settings/presentation/settings_screen.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

enum AppNavDestination { home, documents, uiKit, settings }

class AppNavTab {
  const AppNavTab({
    required this.destination,
    required this.icon,
    required this.label,
    required this.screen,
  });

  final AppNavDestination destination;
  final IconData icon;
  final String label;
  final Widget screen;
}

abstract final class AppNavTabs {
  static List<AppNavTab> all(AppLocalizations l10n) => [
    AppNavTab(
      destination: AppNavDestination.home,
      icon: AppIcons.house,
      label: l10n.navHome,
      screen: const HomeScreen(),
    ),
    AppNavTab(
      destination: AppNavDestination.documents,
      icon: AppIcons.fileText,
      label: l10n.navDocuments,
      screen: const DocumentsScreen(),
    ),
    if (kDebugMode)
      AppNavTab(
        destination: AppNavDestination.uiKit,
        icon: AppIcons.palette,
        label: l10n.navUiKit,
        screen: const UiKitGalleryScreen(),
      ),
    AppNavTab(
      destination: AppNavDestination.settings,
      icon: AppIcons.settings,
      label: l10n.navSettings,
      screen: const SettingsScreen(),
    ),
  ];
}
