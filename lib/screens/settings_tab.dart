import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart' show FSwitch;

import '../core/ui_kit/ui_kit.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) => AppScrollArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppHeader.topInset(context) + AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(child: _AutoSyncRow()),
          const AppGap.lg(),
          AppCard(child: _MarkAsReadRow()),
        ],
      ),
    ),
  );
}

class _AutoSyncRow extends StatefulWidget {
  @override
  State<_AutoSyncRow> createState() => _AutoSyncRowState();
}

class _AutoSyncRowState extends State<_AutoSyncRow> {
  bool _enabled = true;

  @override
  Widget build(BuildContext context) => AppRow(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text('Auto-sync annotations'),
      FSwitch(
        value: _enabled,
        onChange: (value) => setState(() => _enabled = value),
      ),
    ],
  );
}

class _MarkAsReadRow extends StatefulWidget {
  @override
  State<_MarkAsReadRow> createState() => _MarkAsReadRowState();
}

class _MarkAsReadRowState extends State<_MarkAsReadRow> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) => AppCheckbox(
    value: _checked,
    onChanged: (value) => setState(() => _checked = value),
    label: 'Mark new documents as read automatically',
  );
}
