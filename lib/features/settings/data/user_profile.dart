class UserProfile {
  const UserProfile({required this.name});

  static const empty = UserProfile(name: '');

  final String name;

  List<String> get _nameParts => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();

  String get initials {
    final parts = _nameParts;
    if (parts.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  /// The first token of [name], or `''` if no name has been set.
  String get firstName => _nameParts.firstOrNull ?? '';

  UserProfile copyWith({String? name}) => UserProfile(name: name ?? this.name);
}
