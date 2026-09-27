import 'package:flutter/painting.dart';

enum TagColor { red, orange, yellow, green, blue, purple, pink, gray }

extension TagColorValue on TagColor {
  Color get value => switch (this) {
    TagColor.red => const Color(0xFFEF4444),
    TagColor.orange => const Color(0xFFF97316),
    TagColor.yellow => const Color(0xFFEAB308),
    TagColor.green => const Color(0xFF22C55E),
    TagColor.blue => const Color(0xFF3B82F6),
    TagColor.purple => const Color(0xFFA855F7),
    TagColor.pink => const Color(0xFFEC4899),
    TagColor.gray => const Color(0xFF6B7280),
  };
}
