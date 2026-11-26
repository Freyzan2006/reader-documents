import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/documents_providers.dart';

class FavoritesNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final all = await ref.read(favoritesRepositoryProvider).loadAll();
    return all.keys.toSet();
  }

  /// Returns the resulting favorite state, so callers can give feedback
  /// without reading [isFavoriteProvider] a second time.
  Future<bool> toggle(String documentPath) async {
    final current = state.value ?? const {};
    final favorite = !current.contains(documentPath);
    final repo = ref.read(favoritesRepositoryProvider);
    if (favorite) {
      await repo.save(documentPath, true);
      state = AsyncData({...current, documentPath});
    } else {
      await repo.clear(documentPath);
      state = AsyncData({...current}..remove(documentPath));
    }
    return favorite;
  }

  Future<void> setMany(Iterable<String> paths, bool favorite) async {
    final repo = ref.read(favoritesRepositoryProvider);
    final next = {...state.value ?? const <String>{}};
    for (final path in paths) {
      if (favorite) {
        await repo.save(path, true);
        next.add(path);
      } else {
        await repo.clear(path);
        next.remove(path);
      }
    }
    state = AsyncData(next);
  }
}

final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);
