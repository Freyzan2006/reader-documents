import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/config/app_brand.dart';
import 'package:reader_documents/core/device/device_profile.dart';
import 'package:reader_documents/core/device/device_providers.dart';
import 'package:reader_documents/core/device/graphics_mode_resolver.dart';
import 'package:reader_documents/core/localization/app_locale_resolver.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/settings/application/settings_providers.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import 'app_bootstrap.dart';

class Application extends ConsumerWidget {
  const Application({super.key});

  static const _graphics = GraphicsModeResolver();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value ?? AppSettings.defaults;
    final device =
        ref.watch(deviceProfileProvider).value ?? DeviceProfile.unknown;
    final brightness = settings.resolveBrightness(
      MediaQuery.platformBrightnessOf(context),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppBrand.name,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: settings.language.locale,
      localeResolutionCallback: (locale, supportedLocales) =>
          AppLocaleResolver.resolve(locale, supportedLocales),
      builder: (context, child) {
        final reduceMotion = MediaQuery.disableAnimationsOf(context);
        return AppTheme(
          tokens: AppTokens(
            palette: AppPalette.of(brightness, settings.palette),
            graphics: _graphics.resolve(
              preference: settings.effectsMode,
              device: device,
              platformReducesMotion: reduceMotion,
            ),
            reduceMotion: reduceMotion,
          ),
          child: AppToaster(child: child!),
        );
      },
      home: const AppBootstrap(),
    );
  }
}
