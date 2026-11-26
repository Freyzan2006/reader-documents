import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../controls/icon_button.dart';
import '../data_display/text.dart';
import '../tokens/app_icons.dart';
import '../tokens/app_spacing.dart';
import 'header.dart';

class AppSelectionAction {
  const AppSelectionAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.destructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool destructive;
}

class AppSelectionHeader extends StatelessWidget {
  const AppSelectionHeader({
    required this.title,
    required this.closeLabel,
    required this.onClose,
    this.actions = const [],
    super.key,
  });

  final String title;
  final String closeLabel;
  final VoidCallback onClose;
  final List<AppSelectionAction> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return AppHeaderSurface(
      child: FHeader.nested(
        style: const FHeaderStyleDelta.delta(
          constraints: AppHeader.constraints,
          actionSpacing: AppSpacing.md,
        ),
        titleAlignment: Alignment.centerLeft,
        title: AppText(title, variant: AppTextVariant.title),
        prefixes: [
          AppIconButton(
            icon: AppIcons.x,
            onPressed: onClose,
            semanticsLabel: closeLabel,
          ),
        ],
        suffixes: [
          for (final action in actions)
            AppIconButton(
              icon: action.icon,
              onPressed: action.onPressed,
              semanticsLabel: action.label,
              color: action.destructive ? colors.destructive : null,
            ),
        ],
      ),
    );
  }
}
