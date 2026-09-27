import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/documents_providers.dart';

class FavoritesNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final all = await ref.read(favoritesRepositoryProvider).loadAll();
    return all.keys.toSet();
  }

  Future<void> toggle(String documentPath) async {
    final current = state.value ?? const {};
    final repo = ref.read(favoritesRepositoryProvider);
    if (current.contains(documentPath)) {
      await repo.clear(documentPath);
      state = AsyncData({...current}..remove(documentPath));
    } else {
      await repo.save(documentPath, true);
      state = AsyncData({...current, documentPath});
    }
  }
}

final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);
