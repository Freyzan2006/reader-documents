import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class AppOtpField extends StatelessWidget {
  const AppOtpField({
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    super.key,
  });

  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  @override
  Widget build(BuildContext context) => FOtpField(
    control: FOtpFieldControl.managed(
      children: List.generate(length, (_) => const FOtpItem()),
      onChange: onChanged == null && onCompleted == null
          ? null
          : (value) {
              onChanged?.call(value.text);
              if (value.text.length == length) onCompleted?.call(value.text);
            },
    ),
  );
}
