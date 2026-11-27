import 'package:reader_documents/core/storage/flat_global_store.dart';
import 'package:reader_documents/features/settings/data/app_language.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository extends FlatGlobalStore<AppSettings> {
  const SettingsRepository();

  static const _themeModeKey = 'settings.themeMode';
  static const _languageKey = 'settings.language';
  static const _warmReadingFilterKey = 'settings.warmReadingFilter';
  static const _effectsModeKey = 'settings.effectsMode';
  static const _documentsLayoutKey = 'settings.documentsLayout';

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
    final effectsMode = AppEffectsMode.values.firstWhere(
      (mode) => mode.name == prefs.getString(_effectsModeKey),
      orElse: () => AppEffectsMode.system,
    );

    final documentsLayout = DocumentsLayout.values.firstWhere(
      (layout) => layout.name == prefs.getString(_documentsLayoutKey),
      orElse: () => DocumentsLayout.list,
    );

    return AppSettings(
      themeMode: themeMode,
      language: language,
      warmReadingFilter: prefs.getBool(_warmReadingFilterKey) ?? false,
      effectsMode: effectsMode,
      documentsLayout: documentsLayout,
    );
  }

  @override
  Future<void> writeFields(
    SharedPreferences prefs,
    AppSettings settings,
  ) async {
    await prefs.setString(_themeModeKey, settings.themeMode.name);
    await prefs.setString(_languageKey, settings.language.name);
    await prefs.setBool(_warmReadingFilterKey, settings.warmReadingFilter);
    await prefs.setString(_effectsModeKey, settings.effectsMode.name);
    await prefs.setString(_documentsLayoutKey, settings.documentsLayout.name);
  }
}
