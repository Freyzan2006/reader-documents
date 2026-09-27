import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/documents_providers.dart';

class RecentlyOpenedNotifier extends AsyncNotifier<Map<String, DateTime>> {
  @override
  Future<Map<String, DateTime>> build() =>
      ref.read(recentlyOpenedRepositoryProvider).loadAll();

  Future<void> markOpened(String documentPath) async {
    final repository = ref.read(recentlyOpenedRepositoryProvider);
    await repository.save(documentPath, DateTime.now());
    state = AsyncData({
      ...state.value ?? const {},
      documentPath: DateTime.now(),
    });
  }
}

final recentlyOpenedProvider =
    AsyncNotifierProvider<RecentlyOpenedNotifier, Map<String, DateTime>>(
      RecentlyOpenedNotifier.new,
    );
