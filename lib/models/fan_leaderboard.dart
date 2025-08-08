class FanLeaderboard {
  final String id;
  final String username;
  final String avatarUrl;
  final int points;
  final int rank;
  final String badge;
  final int gamesAttended;
  final int postsShared;

  FanLeaderboard({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.points,
    required this.rank,
    required this.badge,
    required this.gamesAttended,
    required this.postsShared,
  });

  factory FanLeaderboard.fromJson(Map<String, dynamic> json) {
    return FanLeaderboard(
      id: json['id'],
      username: json['username'],
      avatarUrl: json['avatarUrl'],
      points: json['points'],
      rank: json['rank'],
      badge: json['badge'],
      gamesAttended: json['gamesAttended'],
      postsShared: json['postsShared'],
    );
  }
}
