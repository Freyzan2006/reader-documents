import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/features/settings/data/app_language.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';
import 'package:reader_documents/features/settings/data/settings_repository.dart';
import 'package:reader_documents/features/settings/data/user_profile.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => const SettingsRepository(),
);

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() => ref.read(settingsRepositoryProvider).load();

  Future<void> setThemeMode(AppThemeMode mode) =>
      _update((settings) => settings.copyWith(themeMode: mode));

  Future<void> setLanguage(AppLanguage language) =>
      _update((settings) => settings.copyWith(language: language));

  Future<void> updateProfile(UserProfile profile) =>
      _update((settings) => settings.copyWith(profile: profile));

  /// Returns the resulting filter state, so callers don't have to duplicate
  /// the inversion or re-read [settingsProvider] to build a toast.
  Future<bool> toggleWarmReadingFilter() async {
    final enabled = !(state.value ?? AppSettings.defaults).warmReadingFilter;
    await _update((settings) => settings.copyWith(warmReadingFilter: enabled));
    return enabled;
  }

  Future<void> setEffectsMode(AppEffectsMode mode) =>
      _update((settings) => settings.copyWith(effectsMode: mode));

  Future<void> _update(
    AppSettings Function(AppSettings current) transform,
  ) async {
    final next = transform(state.value ?? AppSettings.defaults);
    state = AsyncData(next);
    await ref.read(settingsRepositoryProvider).save(next);
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
