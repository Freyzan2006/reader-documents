import 'package:flutter/widgets.dart';
import 'package:simple_icons/simple_icons.dart';

class AiProvider {
  const AiProvider({
    required this.label,
    required this.buildUri,
    required this.color,
    this.icon,
    this.prefillsText = true,
  });

  final String label;
  final Uri Function(String selectedText) buildUri;
  final Color color;
  final IconData? icon;

  /// Whether [buildUri] actually pre-fills the selected text in the opened
  /// page. Some providers dropped URL-based prefill support server-side, so
  /// for those we fall back to copying the text to the clipboard instead.
  final bool prefillsText;
}

abstract final class AiProviders {
  static final gpt = AiProvider(
    label: 'ChatGPT',
    buildUri: (text) => Uri.https('chatgpt.com', '/', {'q': text}),
    color: const Color(0xFF10A37F),
  );

  static final claude = AiProvider(
    label: 'Claude',
    buildUri: (text) => Uri.https('claude.ai', '/new'),
    color: const Color(0xFFD97757),
    icon: SimpleIcons.claude,
    prefillsText: false,
  );

  static final List<AiProvider> all = [gpt, claude];
}

class AiProviderIcon extends StatelessWidget {
  const AiProviderIcon({required this.provider, this.size = 16, super.key});

  final AiProvider provider;
  final double size;

  @override
  Widget build(BuildContext context) {
    final icon = provider.icon;
    if (icon != null) {
      return Icon(icon, size: size, color: provider.color);
    }

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: provider.color,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            provider.label.substring(0, 1),
            style: TextStyle(
              fontSize: size * 0.6,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFFFFF),
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
