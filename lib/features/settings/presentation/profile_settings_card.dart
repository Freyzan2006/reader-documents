import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/settings/data/user_profile.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

class ProfileSettingsCard extends StatefulWidget {
  const ProfileSettingsCard({
    required this.profile,
    required this.onSave,
    super.key,
  });

  final UserProfile profile;
  final ValueChanged<UserProfile> onSave;

  @override
  State<ProfileSettingsCard> createState() => _ProfileSettingsCardState();
}

class _ProfileSettingsCardState extends State<ProfileSettingsCard> {
  late final _nameController = TextEditingController(text: widget.profile.name);
  late final _emailController = TextEditingController(
    text: widget.profile.email,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _save() => widget.onSave(
    UserProfile(name: _nameController.text, email: _emailController.text),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.md,
        children: [
          AppRow(
            children: [
              AppAvatar(initials: widget.profile.initials),
              AppText(l10n.profileSectionTitle, variant: AppTextVariant.body),
            ],
          ),
          AppInput(controller: _nameController, label: l10n.nameLabel),
          AppInput(controller: _emailController, label: l10n.emailLabel),
          AppButton(
            mainAxisSize: MainAxisSize.min,
            onPressed: _save,
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
