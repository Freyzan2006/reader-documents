import 'package:flutter/widgets.dart';
import 'package:simple_icons/simple_icons.dart';

class SearchProvider {
  const SearchProvider({
    required this.label,
    required this.buildUri,
    required this.icon,
    this.color,
  });

  final String label;
  final Uri Function(String selectedText, String languageCode) buildUri;
  final IconData icon;

  /// The provider's brand color, or `null` when its mark is monochrome and
  /// should instead be tinted with the ambient theme's foreground color.
  final Color? color;
}

abstract final class SearchProviders {
  static final google = SearchProvider(
    label: 'Google',
    buildUri: (text, languageCode) =>
        Uri.https('www.google.com', '/search', {'q': text, 'hl': languageCode}),
    icon: SimpleIcons.google,
    color: const Color(0xFF4285F4),
  );

  static final wikipedia = SearchProvider(
    label: 'Wikipedia',
    buildUri: (text, languageCode) => Uri.https(
      '$languageCode.wikipedia.org',
      '/w/index.php',
      {'search': text},
    ),
    icon: SimpleIcons.wikipedia,
  );

  static final List<SearchProvider> all = [google, wikipedia];
}
