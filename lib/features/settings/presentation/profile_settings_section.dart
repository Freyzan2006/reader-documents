import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/settings/data/user_profile.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

class ProfileSettingsSection extends StatefulWidget {
  const ProfileSettingsSection({
    required this.profile,
    required this.onSave,
    super.key,
  });

  final UserProfile profile;
  final ValueChanged<UserProfile> onSave;

  @override
  State<ProfileSettingsSection> createState() => _ProfileSettingsSectionState();
}

class _ProfileSettingsSectionState extends State<ProfileSettingsSection> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.profile.name;
    // Keeps the field in step when the profile is replaced from elsewhere
    // (a settings reload, say) — without this the greeting would update while
    // the input kept showing the old name.
    _nameController.addListener(_syncDirty);
  }

  @override
  void didUpdateWidget(ProfileSettingsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile.name != oldWidget.profile.name) {
      _nameController.text = widget.profile.name;
    }
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_syncDirty)
      ..dispose();
    super.dispose();
  }

  void _syncDirty() => setState(() {});

  /// Nothing to save until the field actually differs from what is stored.
  bool get _isDirty => _nameController.text != widget.profile.name;

  void _save() {
    widget.onSave(UserProfile(name: _nameController.text));
    AppToast.show(
      context: context,
      title: Text(AppLocalizations.of(context)!.saved),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppSection(
      title: l10n.profileSectionTitle,
      icon: AppIcons.user,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.md,
        children: [
          AppRow(
            children: [
              AppAvatar(
                // An empty name yields no initials, so fall back to a neutral
                // silhouette rather than showing a literal "?".
                initials: widget.profile.initialsOrNull,
                fallbackIcon: AppIcons.lamp,
              ),
              AppText(widget.profile.name, variant: AppTextVariant.body),
            ],
          ),
          AppInput(controller: _nameController, label: l10n.nameLabel),
          AppButton(
            mainAxisSize: MainAxisSize.min,
            onPressed: _isDirty ? _save : null,
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
