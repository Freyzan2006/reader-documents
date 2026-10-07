import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../theme/app_theme.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';

/// A miniature rendering of the app's own chrome, used to let the user judge
/// a theme by looking at it instead of reading its name.
///
/// [brightnesses] decides the shape: one entry renders a single preview,
/// two render them side by side (which is how "System" shows that it means
/// *both* light and dark). Each pane is wrapped in its own [FTheme], so every
/// colour below comes from the real [AppTheme] palette for that brightness.
///
/// Deliberately built from fixed-size bars and no text: a preview has to stay
/// legible when shrunk to a card, and text would also reflow unpredictably
/// under large accessibility text scales.
class AppThemePreview extends StatelessWidget {
  const AppThemePreview({required this.brightnesses, super.key});

  /// One pane per entry, laid out left to right.
  final List<Brightness> brightnesses;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: AppRadius.of(context).sm,
    child: switch (brightnesses) {
      [final single] => _Pane(brightness: single),
      _ => Row(
        children: [
          for (final brightness in brightnesses)
            Expanded(child: _Pane(brightness: brightness)),
        ],
      ),
    },
  );
}

/// A single preview pane, themed independently of its siblings.
class _Pane extends StatelessWidget {
  const _Pane({required this.brightness});

  final Brightness brightness;

  static const _minWidth = 64.0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = math.min(1.0, constraints.maxWidth / _minWidth);
      return FittedBox(
        fit: BoxFit.fill,
        child: SizedBox(
          width: constraints.maxWidth / scale,
          height: constraints.maxHeight / scale,
          child: _content(context),
        ),
      );
    },
  );

  Widget _content(BuildContext context) => FTheme(
    data: AppTheme.of(brightness),
    child: Builder(
      builder: (context) {
        final colors = context.theme.colors;

        return DecoratedBox(
          decoration: BoxDecoration(color: colors.background),
          child: Column(
            spacing: AppSpacing.xs,
            children: [
              // Header bar.
              _Bar(
                color: colors.muted,
                height: 7,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Row(
                    spacing: 2,
                    children: [
                      // Menu glyph.
                      _Bar(color: colors.mutedForeground, width: 3, height: 3),
                      _Bar(color: colors.mutedForeground, width: 14, height: 3),
                      const Spacer(),
                      // The app's primary accent — the single most important
                      // colour to show, since the brand is monochrome and this
                      // is the one thing that differs most between themes.
                      _Bar(color: colors.primary, width: 12, height: 5),
                    ],
                  ),
                ),
              ),
              // Sidebar + content.
              Expanded(
                child: Row(
                  spacing: AppSpacing.xs,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Column(
                        spacing: AppSpacing.xs,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Bar(color: colors.primary, width: 10, height: 3),
                          _Bar(color: colors.border, width: 14, height: 3),
                          _Bar(color: colors.border, width: 14, height: 3),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        spacing: AppSpacing.xs,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Bar(color: colors.foreground, width: 22, height: 4),
                          _Bar(color: colors.border, width: 40, height: 3),
                          _Bar(color: colors.border, width: 32, height: 3),
                          const Spacer(),
                          Row(
                            spacing: 2,
                            children: [
                              _Bar(
                                color: colors.destructive,
                                width: 4,
                                height: 4,
                              ),
                              _Bar(color: colors.border, width: 18, height: 3),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

/// A fixed-size rounded bar — the only drawing primitive this preview needs.
class _Bar extends StatelessWidget {
  const _Bar({required this.color, this.width, this.height = 3, this.child});

  final Color color;

  /// Omitted bars stretch to fill their parent's cross axis.
  final double? width;
  final double height;
  final Widget? child;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: child,
    ),
  );
}
