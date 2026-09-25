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
