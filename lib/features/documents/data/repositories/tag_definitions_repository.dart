import 'package:reader_documents/core/storage/json_global_store.dart';

import '../models/tag_definition.dart';

class TagDefinitionsRepository extends JsonGlobalStore<List<TagDefinition>> {
  const TagDefinitionsRepository();

  @override
  String get key => 'tag_definitions';

  @override
  Object? encode(List<TagDefinition> value) =>
      value.map((d) => d.toJson()).toList();

  @override
  List<TagDefinition> decode(Object? json) => (json as List<dynamic>)
      .map((entry) => TagDefinition.fromJson(entry as Map<String, dynamic>))
      .toList();
}
