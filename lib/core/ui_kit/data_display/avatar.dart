import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// A circular avatar showing an image, falling back to [initials], then to
/// [fallbackIcon] — the last one lets a caller cover the "nothing to show yet"
/// case with a neutral silhouette instead of a placeholder character.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    this.image,
    this.initials,
    this.fallbackIcon,
    this.size = 40,
    super.key,
  });

  final ImageProvider? image;
  final String? initials;

  /// Used only when [initials] is null or empty.
  final IconData? fallbackIcon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final content = switch ((initials?.trim(), fallbackIcon)) {
      (final text?, _) when text.isNotEmpty => Text(text),
      (_, final icon?) => Icon(icon, size: size * 0.5),
      _ => null,
    };

    return image == null
        ? FAvatar.raw(size: size, child: content)
        : FAvatar(image: image!, size: size, fallback: content);
  }
}