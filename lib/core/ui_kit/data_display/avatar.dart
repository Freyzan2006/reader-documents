import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({this.image, this.initials, this.size = 40, super.key});

  final ImageProvider? image;
  final String? initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = initials == null ? null : Text(initials!);
    return image == null
        ? FAvatar.raw(size: size, child: fallback)
        : FAvatar(image: image!, size: size, fallback: fallback);
  }
}
