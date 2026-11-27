import 'package:flutter/widgets.dart';

import '../primitives/tappable.dart';
import '../theme/app_tokens.dart';
import '../tokens/app_icons.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';
import 'badge.dart';

class AppTag extends StatelessWidget {
  const AppTag({
    required this.label,
    this.onRemove,
    this.color,
    this.removeSemanticsLabel,
    super.key,
  });

  static const _height = 26.0;

  final Widget label;
  final VoidCallback? onRemove;
  final Color? color;
  final String? removeSemanticsLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    final custom = color;
    final fill = custom ?? palette.shade;
    final foreground = custom == null ? palette.ink : AppContrast.on(custom);
    final onRemove = this.onRemove;

    return Container(
      height: _height,
      padding: EdgeInsets.only(left: 8, right: onRemove == null ? 8 : 2),
      decoration: BoxDecoration(color: fill, borderRadius: AppRadii.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 2,
        children: [
          Flexible(
            child: DefaultTextStyle.merge(
              style: AppTextStyles.label.copyWith(
                fontSize: 13,
                height: 18 / 13,
                color: foreground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              child: label,
            ),
          ),
          if (onRemove != null)
            AppTappable(
              onPressed: onRemove,
              semanticsLabel: removeSemanticsLabel,
              child: SizedBox.square(
                dimension: 22,
                child: Icon(AppIcons.x, size: 14, color: foreground),
              ),
            ),
        ],
      ),
    );
  }
}
