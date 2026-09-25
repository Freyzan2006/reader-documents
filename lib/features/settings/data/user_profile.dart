class UserProfile {
  const UserProfile({required this.name, required this.email});

  static const empty = UserProfile(name: '', email: '');

  final String name;
  final String email;

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  UserProfile copyWith({String? name, String? email}) =>
      UserProfile(name: name ?? this.name, email: email ?? this.email);
}
