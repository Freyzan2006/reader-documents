import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/storage/json_global_store.dart';

class GestureHintRepository extends JsonGlobalStore<bool> {
  const GestureHintRepository();

  @override
  String get key => 'document_gesture_hint_seen';

  @override
  Object? encode(bool value) => value;

  @override
  bool decode(Object? json) => json as bool;
}

final gestureHintRepositoryProvider = Provider<GestureHintRepository>(
  (ref) => const GestureHintRepository(),
);

class GestureHintNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async =>
      await ref.read(gestureHintRepositoryProvider).load() ?? false;

  Future<void> markSeen() async {
    await ref.read(gestureHintRepositoryProvider).save(true);
    state = const AsyncData(true);
  }

  Future<void> reset() async {
    await ref.read(gestureHintRepositoryProvider).clear();
    state = const AsyncData(false);
  }
}

final gestureHintSeenProvider =
    AsyncNotifierProvider<GestureHintNotifier, bool>(GestureHintNotifier.new);
