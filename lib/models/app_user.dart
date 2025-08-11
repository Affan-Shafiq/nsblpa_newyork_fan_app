class AppUser {
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String teamId;
  final int points;
  final List<String> badges;
  final int postsShared;
  final String role; // New role field

  AppUser({
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.teamId,
    required this.points,
    required this.badges,
    required this.postsShared,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      email: json['email'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      teamId: json['teamId'],
      points: json['points'] ?? 0,
      badges: List<String>.from(json['badges'] ?? []),
      postsShared: json['postsShared'] ?? 0,
      role: json['role'] ?? 'fan', // Default to 'fan'
    );
  }

  factory AppUser.fromFirestore(Map<String, dynamic> data) {
    return AppUser(
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      teamId: data['teamId'] as String? ?? '',
      points: data['points'] as int? ?? 0,
      badges: List<String>.from(data['badges'] ?? []),
      postsShared: data['postsShared'] as int? ?? 0,
      role: data['role'] as String? ?? 'fan', // Default to 'fan'
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'teamId': teamId,
      'points': points,
      'badges': badges,
      'postsShared': postsShared,
      'role': role,
    };
  }

  AppUser copyWith({
    String? email,
    String? displayName,
    String? photoUrl,
    String? teamId,
    int? points,
    List<String>? badges,
    int? postsShared,
    String? role,
  }) {
    return AppUser(
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      teamId: teamId ?? this.teamId,
      points: points ?? this.points,
      badges: badges ?? this.badges,
      postsShared: postsShared ?? this.postsShared,
      role: role ?? this.role,
    );
  }
}


