import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart';

import '../overlay/toast.dart';
import '../primitives/tappable.dart';
import '../theme/app_tokens.dart';
import '../tokens/app_icons.dart';
import '../tokens/app_spacing.dart';
import 'text.dart';

class AppCopyText extends StatelessWidget {
  const AppCopyText(
    this.text, {
    required this.copiedMessage,
    this.variant = AppTextVariant.body,
    this.color,
    this.iconColor,
    this.maxLines,
    this.overflow,
    super.key,
  });

  final String text;
  final String copiedMessage;
  final AppTextVariant variant;
  final Color? color;
  final Color? iconColor;
  final int? maxLines;
  final TextOverflow? overflow;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    AppToast.show(context: context, title: Text(copiedMessage));
  }

  @override
  Widget build(BuildContext context) => AppTappable(
    onPressed: () => _copy(context),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.xs,
      children: [
        Flexible(
          child: AppText(
            text,
            variant: variant,
            color: color,
            maxLines: maxLines,
            overflow: overflow,
          ),
        ),
        Icon(
          AppIcons.copy,
          size: 14,
          color: iconColor ?? context.tokens.palette.ink3,
        ),
      ],
    ),
  );
}
