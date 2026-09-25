import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/tokens/app_icons.dart';

class AiProvider {
  const AiProvider({
    required this.label,
    required this.buildUri,
    required this.color,
    this.icon,
  });

  final String label;
  final Uri Function(String selectedText) buildUri;
  final Color color;
  final IconData? icon;
}

abstract final class AiProviders {
  static final gpt = AiProvider(
    label: 'ChatGPT',
    buildUri: (text) => Uri.https('chatgpt.com', '/', {'q': text}),
    color: const Color(0xFF10A37F),
  );

  static final List<AiProvider> all = [gpt];
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
          child: Icon(
            AppIcons.sparkles,
            size: size * 0.6,
            color: const Color(0xFFFFFFFF),
          ),
        ),
      ),
    );
  }
}
