import 'package:flutter/widgets.dart';

@immutable
final class AppPalette {
  const AppPalette({
    required this.brightness,
    required this.paper,
    required this.sheet,
    required this.shade,
    required this.shadeStrong,
    required this.rule,
    required this.ruleStrong,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.onInk,
    required this.danger,
    required this.onDanger,
    required this.dangerSoft,
    required this.mark,
    required this.scrim,
    required this.scrimSolid,
    required this.glass,
  });

  static const light = AppPalette(
    brightness: Brightness.light,
    paper: Color(0xFFF4F4F3),
    sheet: Color(0xFFFFFFFF),
    shade: Color(0xFFECECEA),
    shadeStrong: Color(0xFFDEDEDC),
    rule: Color(0xFFE2E2E0),
    ruleStrong: Color(0xFF858582),
    ink: Color(0xFF111111),
    ink2: Color(0xFF4B4B49),
    ink3: Color(0xFF686865),
    onInk: Color(0xFFFFFFFF),
    danger: Color(0xFFB3261E),
    onDanger: Color(0xFFFFFFFF),
    dangerSoft: Color(0xFFF9E8E6),
    mark: Color(0x24111111),
    scrim: Color(0x52000000),
    scrimSolid: Color(0x80000000),
    glass: Color(0xB8FFFFFF),
  );

  static const dark = AppPalette(
    brightness: Brightness.dark,
    paper: Color(0xFF0C0C0C),
    sheet: Color(0xFF171717),
    shade: Color(0xFF222222),
    shadeStrong: Color(0xFF2E2E2E),
    rule: Color(0xFF2A2A2A),
    ruleStrong: Color(0xFF6B6B6B),
    ink: Color(0xFFEDEDEB),
    ink2: Color(0xFFB5B5B2),
    ink3: Color(0xFF8C8C89),
    onInk: Color(0xFF111111),
    danger: Color(0xFFFF7A6E),
    onDanger: Color(0xFF111111),
    dangerSoft: Color(0xFF2C1513),
    mark: Color(0x2EEDEDEB),
    scrim: Color(0xA3000000),
    scrimSolid: Color(0xC7000000),
    glass: Color(0xC7171717),
  );

  static AppPalette of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  final Brightness brightness;
  final Color paper;
  final Color sheet;
  final Color shade;
  final Color shadeStrong;
  final Color rule;
  final Color ruleStrong;
  final Color ink;
  final Color ink2;
  final Color ink3;
  final Color onInk;
  final Color danger;
  final Color onDanger;
  final Color dangerSoft;
  final Color mark;
  final Color scrim;
  final Color scrimSolid;
  final Color glass;

  Color get focus => ink;

  static AppPalette lerp(AppPalette a, AppPalette b, double t) => AppPalette(
    brightness: t < 0.5 ? a.brightness : b.brightness,
    paper: Color.lerp(a.paper, b.paper, t)!,
    sheet: Color.lerp(a.sheet, b.sheet, t)!,
    shade: Color.lerp(a.shade, b.shade, t)!,
    shadeStrong: Color.lerp(a.shadeStrong, b.shadeStrong, t)!,
    rule: Color.lerp(a.rule, b.rule, t)!,
    ruleStrong: Color.lerp(a.ruleStrong, b.ruleStrong, t)!,
    ink: Color.lerp(a.ink, b.ink, t)!,
    ink2: Color.lerp(a.ink2, b.ink2, t)!,
    ink3: Color.lerp(a.ink3, b.ink3, t)!,
    onInk: Color.lerp(a.onInk, b.onInk, t)!,
    danger: Color.lerp(a.danger, b.danger, t)!,
    onDanger: Color.lerp(a.onDanger, b.onDanger, t)!,
    dangerSoft: Color.lerp(a.dangerSoft, b.dangerSoft, t)!,
    mark: Color.lerp(a.mark, b.mark, t)!,
    scrim: Color.lerp(a.scrim, b.scrim, t)!,
    scrimSolid: Color.lerp(a.scrimSolid, b.scrimSolid, t)!,
    glass: Color.lerp(a.glass, b.glass, t)!,
  );

  bool get isDark => brightness == Brightness.dark;
}
