import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/storage/json_global_store.dart';
import 'package:reader_documents/features/documents/data/models/document_highlight.dart';

enum SelectionToolKind { translate, ai, search }

final class SelectionTools {
  const SelectionTools({
    this.highlightColor = DocumentHighlightColor.yellow,
    this.providers = const {},
  });

  final DocumentHighlightColor highlightColor;
  final Map<SelectionToolKind, String> providers;

  SelectionTools copyWith({
    DocumentHighlightColor? highlightColor,
    Map<SelectionToolKind, String>? providers,
  }) => SelectionTools(
    highlightColor: highlightColor ?? this.highlightColor,
    providers: providers ?? this.providers,
  );
}

class SelectionToolsRepository extends JsonGlobalStore<SelectionTools> {
  const SelectionToolsRepository();

  @override
  String get key => 'document_selection_tools';

  @override
  Object? encode(SelectionTools value) => {
    'highlightColor': value.highlightColor.name,
    'providers': {
      for (final MapEntry(:key, :value) in value.providers.entries)
        key.name: value,
    },
  };

  @override
  SelectionTools decode(Object? json) {
    final map = json as Map<String, dynamic>;
    final providers = map['providers'] as Map<String, dynamic>? ?? const {};
    return SelectionTools(
      highlightColor: DocumentHighlightColor.values.firstWhere(
        (color) => color.name == map['highlightColor'],
        orElse: () => DocumentHighlightColor.yellow,
      ),
      providers: {
        for (final kind in SelectionToolKind.values)
          if (providers[kind.name] case final String id) kind: id,
      },
    );
  }
}

final selectionToolsRepositoryProvider = Provider<SelectionToolsRepository>(
  (ref) => const SelectionToolsRepository(),
);

class SelectionToolsNotifier extends AsyncNotifier<SelectionTools> {
  @override
  Future<SelectionTools> build() async =>
      await ref.read(selectionToolsRepositoryProvider).load() ??
      const SelectionTools();

  Future<void> useHighlightColor(DocumentHighlightColor color) =>
      _update((tools) => tools.copyWith(highlightColor: color));

  Future<void> useProvider(SelectionToolKind kind, String id) => _update(
    (tools) => tools.copyWith(providers: {...tools.providers, kind: id}),
  );

  Future<void> _update(
    SelectionTools Function(SelectionTools) transform,
  ) async {
    final next = transform(state.value ?? const SelectionTools());
    state = AsyncData(next);
    await ref.read(selectionToolsRepositoryProvider).save(next);
  }
}

final selectionToolsProvider =
    AsyncNotifierProvider<SelectionToolsNotifier, SelectionTools>(
      SelectionToolsNotifier.new,
    );
