import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:reader_documents/core/config/app_brand.dart';
import 'package:reader_documents/core/localization/app_locale_resolver.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/settings/application/settings_providers.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import 'app_bootstrap.dart';

class Application extends ConsumerWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value ?? AppSettings.defaults;
    final brightness = settings.resolveBrightness(
      MediaQuery.platformBrightnessOf(context),
    );
    final theme = AppTheme.of(brightness);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppBrand.name,
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
      home: const AppBootstrap(),
    );
  }
}
