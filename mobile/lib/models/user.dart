class User {
  final String id;
  final String username;
  final String? phone;
  final String? avatar;
  final String? country;
  final String? bio;
  final int streak;
  final int level;
  final int xp;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    this.phone,
    this.avatar,
    this.country,
    this.bio,
    this.streak = 0,
    required this.level,
    required this.xp,
    required this.isPremium,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      country: json['country'] as String?,
      bio: json['bio'] as String?,
      streak: (json['streak'] as int?) ?? 0,
      level: json['level'] as int,
      xp: json['xp'] as int,
      isPremium: json['isPremium'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
