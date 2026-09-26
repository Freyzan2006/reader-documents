import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../overlay/toast.dart';
import '../tokens/app_icons.dart';
import '../tokens/app_spacing.dart';
import 'text.dart';

/// Text with a tap-to-copy affordance. Copies [text] to the clipboard on
/// tap and confirms with a toast.
class AppCopyText extends StatelessWidget {
  const AppCopyText(
    this.text, {
    this.variant = AppTextVariant.body,
    this.color,
    this.iconColor,
    this.maxLines,
    this.overflow,
    super.key,
  });

  final String text;
  final AppTextVariant variant;
  final Color? color;
  final Color? iconColor;
  final int? maxLines;
  final TextOverflow? overflow;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    AppToast.show(context: context, title: const Text('Copied to clipboard'));
  }

  @override
  Widget build(BuildContext context) => FTappable(
    onPress: () => _copy(context),
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
          color: iconColor ?? context.theme.colors.mutedForeground,
        ),
      ],
    ),
  );
}
