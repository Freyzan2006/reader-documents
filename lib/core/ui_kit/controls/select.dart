import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class AppSelect<T> extends StatelessWidget {
  const AppSelect({
    required this.items,
    this.initial,
    this.onChanged,
    this.label,
    this.hint,
    this.enabled = true,
    super.key,
  });

  final Map<String, T> items;
  final T? initial;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String? hint;
  final bool enabled;

  @override
  Widget build(BuildContext context) => FSelect<T>(
    items: items,
    control: FSelectControl.managed(initial: initial, onChange: onChanged),
    label: label == null ? null : Text(label!),
    hint: hint,
    enabled: enabled,
  );
}
