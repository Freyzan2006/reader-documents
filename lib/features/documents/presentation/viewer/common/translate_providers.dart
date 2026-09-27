import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/tokens/app_icons.dart';
import 'package:simple_icons/simple_icons.dart';

class TranslateProvider {
  const TranslateProvider({
    required this.label,
    required this.buildUri,
    required this.color,
    required this.icon,
  });

  final String label;
  final Uri Function(String selectedText, String targetLanguageCode) buildUri;
  final Color color;
  final IconData icon;
}

abstract final class TranslateProviders {
  static final google = TranslateProvider(
    label: 'Google Translate',
    buildUri: (text, targetLanguageCode) => Uri.https(
      'translate.google.com',
      '/',
      {'sl': 'auto', 'tl': targetLanguageCode, 'text': text, 'op': 'translate'},
    ),
    color: const Color(0xFF4285F4),
    icon: SimpleIcons.googletranslate,
  );

  static final yandex = TranslateProvider(
    label: 'Yandex Translate',
    buildUri: (text, targetLanguageCode) => Uri.https(
      'translate.yandex.com',
      '/',
      {'source_lang': 'auto', 'target_lang': targetLanguageCode, 'text': text},
    ),
    color: const Color(0xFFFC3F1D),
    icon: AppIcons.languages,
  );

  static final List<TranslateProvider> all = [google, yandex];
}
