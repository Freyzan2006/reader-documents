import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/core/ui_kit/tokens/app_palette.dart';

/// WCAG 2.x contrast ratio between two opaque colors.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  for (final family in AppPaletteFamily.values) {
    for (final brightness in Brightness.values) {
      final palette = AppPalette.of(brightness, family);
      final name = '${family.name}/${brightness.name}';

      test('$name resolves to its own family and brightness', () {
        expect(palette.family, family);
        expect(palette.brightness, brightness);
      });

      test('$name text meets WCAG AA (4.5:1)', () {
        final pairs = {
          'ink on paper': (palette.ink, palette.paper),
          'ink on sheet': (palette.ink, palette.sheet),
          'ink2 on paper': (palette.ink2, palette.paper),
          'ink2 on sheet': (palette.ink2, palette.sheet),
          'ink3 on paper': (palette.ink3, palette.paper),
          'ink3 on sheet': (palette.ink3, palette.sheet),
          'ink2 on shade': (palette.ink2, palette.shade),
          'onInk on ink': (palette.onInk, palette.ink),
          'onDanger on danger': (palette.onDanger, palette.danger),
          'danger on sheet': (palette.danger, palette.sheet),
        };
        for (final MapEntry(key: label, value: (fg, bg)) in pairs.entries) {
          expect(
            _contrast(fg, bg),
            greaterThanOrEqualTo(4.5),
            reason: '$name: $label',
          );
        }
      });
    }
  }
}
