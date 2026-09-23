import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class AppSlider extends StatelessWidget {
  const AppSlider({
    this.value = 0.25,
    this.onChanged,
    this.enabled = true,
    super.key,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) => FSlider(
    control: FSliderControl.managedContinuous(
      initial: FSliderValue(max: value),
      onChange: onChanged == null ? null : (v) => onChanged!(v.max),
    ),
    enabled: enabled,
  );
}
