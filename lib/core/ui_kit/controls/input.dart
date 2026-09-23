import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// A single-line text input. Wraps Forui's [FTextField], exposing a small,
/// opinionated subset of its (very large) parameter surface — the rest is
/// still reachable by using [FTextField] directly for cases this doesn't
/// cover.
class AppInput extends StatelessWidget {
  const AppInput({
    this.controller,
    this.label,
    this.hint,
    this.onChanged,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;

  @override
  Widget build(BuildContext context) => FTextField(
    control: FTextFieldControl.managed(
      controller: controller,
      onChange: onChanged == null ? null : (value) => onChanged!(value.text),
    ),
    label: label == null ? null : Text(label!),
    hint: hint,
    obscureText: obscureText,
    enabled: enabled,
    autofocus: autofocus,
  );
}
