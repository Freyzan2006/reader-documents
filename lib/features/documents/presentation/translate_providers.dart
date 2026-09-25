import 'package:flutter/widgets.dart';
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

  static final List<TranslateProvider> all = [google];
}
