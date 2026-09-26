import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../tokens/app_icons.dart';
import '../tokens/app_spacing.dart';
import 'icon_button.dart';

/// A single-line numeric text input with decrement/increment stepper
/// buttons. Wraps Forui's [FTextField] with a digits-only keyboard and
/// input filter baked in.
class AppNumberInput extends StatefulWidget {
  const AppNumberInput({
    this.controller,
    this.label,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.min,
    this.max,
    this.debounce,
    this.enabled = true,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final ValueChanged<int?>? onChanged;
  final ValueChanged<int?>? onSubmitted;

  /// Delay before [onChanged] fires after a keystroke, so a value acted on
  /// mid-typing (e.g. driving navigation) doesn't fire on every partial
  /// digit. Does not affect the stepper buttons or [onSubmitted] — both are
  /// already single, deliberate actions. `null` (default) fires immediately.
  final Duration? debounce;

  /// Inclusive lower bound. Stepping below it is a no-op; typed values are
  /// clamped up to it once the field is confirmed.
  final int? min;

  /// Inclusive upper bound. Stepping above it is a no-op; typed values are
  /// clamped down to it once the field is confirmed.
  final int? max;

  final bool enabled;
  final bool autofocus;

  @override
  State<AppNumberInput> createState() => _AppNumberInputState();
}

class _AppNumberInputState extends State<AppNumberInput> {
  late final TextEditingController _controller;
  var _ownsController = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    final controller = widget.controller;
    if (controller != null) {
      _controller = controller;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _handleTyped(String text) {
    final value = int.tryParse(text);
    final debounce = widget.debounce;
    if (debounce == null) {
      widget.onChanged!(value);
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () => widget.onChanged!(value));
  }

  int? get _value => int.tryParse(_controller.text);

  int _clamp(int value) {
    var result = value;
    final min = widget.min;
    final max = widget.max;
    if (min != null && result < min) result = min;
    if (max != null && result > max) result = max;
    return result;
  }

  void _setValue(int value) {
    final clamped = _clamp(value);
    _debounceTimer?.cancel();
    setState(() {
      _controller.text = clamped.toString();
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    });
    widget.onChanged?.call(clamped);
  }

  void _step(int delta) => _setValue((_value ?? (widget.min ?? 0)) + delta);

  @override
  Widget build(BuildContext context) {
    final value = _value;
    final atMin = widget.min != null && value != null && value <= widget.min!;
    final atMax = widget.max != null && value != null && value >= widget.max!;

    return Row(
      spacing: AppSpacing.xs,
      children: [
        AppIconButton(
          icon: AppIcons.minus,
          onPressed: widget.enabled && !atMin ? () => _step(-1) : null,
        ),
        Expanded(
          child: FTextField(
            control: FTextFieldControl.managed(
              controller: _controller,
              onChange: widget.onChanged == null
                  ? null
                  : (value) => _handleTyped(value.text),
            ),
            label: widget.label == null ? null : Text(widget.label!),
            hint: widget.hint,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmit: widget.onSubmitted == null
                ? null
                : (text) {
                    _debounceTimer?.cancel();
                    widget.onSubmitted!(int.tryParse(text));
                  },
            enabled: widget.enabled,
            autofocus: widget.autofocus,
          ),
        ),
        AppIconButton(
          icon: AppIcons.plus,
          onPressed: widget.enabled && !atMax ? () => _step(1) : null,
        ),
      ],
    );
  }
}
