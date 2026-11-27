import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.message,
    this.icon,
    this.description,
    this.action,
    super.key,
  });

  static const _textWidth = 260.0;

  final IconData? icon;
  final String message;
  final String? description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    final description = this.description;
    final action = this.action;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl3,
        horizontal: AppSpacing.xl,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _EmptyArt(icon: icon),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle.copyWith(color: palette.ink),
            ),
            if (description != null) ...[
              const SizedBox(height: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _textWidth),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(color: palette.ink2),
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action,
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyArt extends StatelessWidget {
  const _EmptyArt({this.icon});

  static const _sheetWidth = 48.0;
  static const _sheetHeight = 48 * 1.414;

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    final icon = this.icon;
    BoxDecoration sheet(Color color) => BoxDecoration(
      color: color,
      borderRadius: AppRadii.xs,
      border: Border.all(color: palette.ruleStrong, width: 1.5),
    );

    return SizedBox(
      width: 64,
      height: 80,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 8,
            child: Transform.rotate(
              angle: -8 * math.pi / 180,
              child: Container(
                width: _sheetWidth,
                height: _sheetHeight,
                decoration: sheet(palette.shade),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: _sheetWidth,
              height: _sheetHeight,
              decoration: sheet(palette.sheet),
              child: icon == null
                  ? null
                  : Icon(icon, size: 20, color: palette.ink2),
            ),
          ),
        ],
      ),
    );
  }
}
