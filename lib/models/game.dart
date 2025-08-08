class Game {
  final String id;
  final String opponent;
  final DateTime dateTime;
  final String venue;
  final String? score;
  final bool isHome;
  final String status; // 'upcoming', 'live', 'completed'
  final String? ticketUrl;

  Game({
    required this.id,
    required this.opponent,
    required this.dateTime,
    required this.venue,
    this.score,
    required this.isHome,
    required this.status,
    this.ticketUrl,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      opponent: json['opponent'],
      dateTime: DateTime.parse(json['dateTime']),
      venue: json['venue'],
      score: json['score'],
      isHome: json['isHome'],
      status: json['status'],
      ticketUrl: json['ticketUrl'],
    );
  }

  bool get isUpcoming => status == 'upcoming';
  bool get isLive => status == 'live';
  bool get isCompleted => status == 'completed';
}
