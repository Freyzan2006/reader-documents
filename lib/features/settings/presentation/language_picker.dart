import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/localization/app_locale_resolver.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/settings/data/app_language.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

class LanguagePicker {
  const LanguagePicker(this._l10n);

  static const _languages = [AppLanguage.ru, AppLanguage.uz, AppLanguage.en];

  final AppLocalizations _l10n;

  static Future<AppLanguage?> show(
    BuildContext context, {
    required AppLanguage selected,
  }) {
    final picker = LanguagePicker(AppLocalizations.of(context)!);
    return AppChoiceSheet.show<AppLanguage>(
      context: context,
      title: picker._l10n.languagePickerTitle,
      meta: picker._l10n.languagesCount(_languages.length),
      footnote: picker._l10n.languageAppliesNow,
      selected: selected,
      choices: picker._choices(),
    );
  }

  String label(AppLanguage language) => language == AppLanguage.system
      ? _l10n.systemLanguage
      : language.nativeName;

  AppLanguage get systemResolved {
    final locale = AppLocaleResolver.resolve(
      PlatformDispatcher.instance.locale,
      AppLocalizations.supportedLocales,
    );
    return _languages.firstWhere(
      (language) => language.locale?.languageCode == locale.languageCode,
      orElse: () => AppLanguage.ru,
    );
  }

  String _localizedName(AppLanguage language) => switch (language) {
    AppLanguage.system => _l10n.systemLanguage,
    AppLanguage.ru => _l10n.languageNameRu,
    AppLanguage.en => _l10n.languageNameEn,
    AppLanguage.uz => _l10n.languageNameUz,
  };

  List<AppChoice<AppLanguage>> _choices() => [
    AppChoice(
      value: AppLanguage.system,
      title: _l10n.systemLanguage,
      subtitle: _l10n.nowValue(systemResolved.nativeName),
    ),
    for (final language in _languages)
      AppChoice(
        value: language,
        title: language.nativeName,
        subtitle: _localizedName(language),
        code: language.code,
      ),
  ];
}
