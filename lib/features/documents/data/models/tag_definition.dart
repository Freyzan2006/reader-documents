import 'tag_color.dart';

class TagDefinition {
  const TagDefinition({required this.name, required this.color});

  factory TagDefinition.fromJson(Map<String, dynamic> json) => TagDefinition(
    name: json['name'] as String,
    color: TagColor.values.byName(json['color'] as String),
  );

  final String name;
  final TagColor color;

  Map<String, dynamic> toJson() => {'name': name, 'color': color.name};
}
