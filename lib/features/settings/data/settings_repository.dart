import 'package:reader_documents/core/storage/flat_global_store.dart';
import 'package:reader_documents/features/settings/data/app_language.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';
import 'package:reader_documents/features/settings/data/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository extends FlatGlobalStore<AppSettings> {
  const SettingsRepository();

  static const _themeModeKey = 'settings.themeMode';
  static const _languageKey = 'settings.language';
  static const _profileNameKey = 'settings.profile.name';
  static const _warmReadingFilterKey = 'settings.warmReadingFilter';

  @override
  Future<AppSettings> readFields(SharedPreferences prefs) async {
    final themeMode = AppThemeMode.values.firstWhere(
      (mode) => mode.name == prefs.getString(_themeModeKey),
      orElse: () => AppThemeMode.system,
    );
    final language = AppLanguage.values.firstWhere(
      (language) => language.name == prefs.getString(_languageKey),
      orElse: () => AppLanguage.system,
    );

    return AppSettings(
      themeMode: themeMode,
      language: language,
      profile: UserProfile(name: prefs.getString(_profileNameKey) ?? ''),
      warmReadingFilter: prefs.getBool(_warmReadingFilterKey) ?? false,
    );
  }

  @override
  Future<void> writeFields(
    SharedPreferences prefs,
    AppSettings settings,
  ) async {
    await prefs.setString(_themeModeKey, settings.themeMode.name);
    await prefs.setString(_languageKey, settings.language.name);
    await prefs.setString(_profileNameKey, settings.profile.name);
    await prefs.setBool(_warmReadingFilterKey, settings.warmReadingFilter);
  }
}
