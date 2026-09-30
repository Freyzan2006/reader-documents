class UserProfile {
  const UserProfile({required this.name});

  static const empty = UserProfile(name: '');

  final String name;

  List<String> get _nameParts => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();

  /// Up to two letters standing in for [name] in an avatar, or `null` when no
  /// name has been set — callers render an icon placeholder instead of a
  /// literal "?" in that case.
  String? get initialsOrNull {
    final parts = _nameParts;
    if (parts.isEmpty) return null;
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  /// The first token of [name], or `''` if no name has been set.
  String get firstName => _nameParts.firstOrNull ?? '';

  UserProfile copyWith({String? name}) => UserProfile(name: name ?? this.name);
}
