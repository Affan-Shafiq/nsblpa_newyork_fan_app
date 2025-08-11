import 'package:cloud_firestore/cloud_firestore.dart';

class GameSide {
  final String sideId;
  final String sideName;

  GameSide({
    required this.sideId,
    required this.sideName,
  });

  factory GameSide.fromJson(Map<String, dynamic> json) {
    return GameSide(
      sideId: json['sideId'] as String,
      sideName: json['sideName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sideId': sideId,
      'sideName': sideName,
    };
  }
}

class Game {
  final List<GameSide> sides;
  final DateTime dateTime;
  final String? score;
  final String status; // 'upcoming', 'live', 'completed'

  Game({
    required this.sides,
    required this.dateTime,
    this.score,
    required this.status,
  });

  // Helper getters for backward compatibility
  String getOpponent(String teamId) {
    // Find the opponent (the side that is not the current team)
    final opponentSide = sides.firstWhere(
      (side) => side.sideId != teamId,
      orElse: () => GameSide(sideId: '', sideName: 'Unknown'),
    );
    return opponentSide.sideName;
  }

  String getOpponentId(String teamId) {
    // Find the opponent ID (the side that is not the current team)
    final opponentSide = sides.firstWhere(
      (side) => side.sideId != teamId,
      orElse: () => GameSide(sideId: '', sideName: 'Unknown'),
    );
    return opponentSide.sideId;
  }

  String get homeTeam {
    // For now, assume the first side is home team
    return sides.isNotEmpty ? sides.first.sideName : '';
  }

  String get awayTeam {
    // For now, assume the second side is away team
    return sides.length > 1 ? sides[1].sideName : '';
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    final sidesList = json['sides'] as List<dynamic>? ?? [];
    final sides = sidesList.map((side) => GameSide.fromJson(side as Map<String, dynamic>)).toList();
    
    return Game(
      sides: sides,
      dateTime: _parseTimestamp(json['dateTime']) ?? DateTime.now(),
      score: json['score'] as String?,
      status: json['status'] as String,
    );
  }

  factory Game.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final sidesList = data['sides'] as List<dynamic>? ?? [];
    final sides = sidesList.map((side) => GameSide.fromJson(side as Map<String, dynamic>)).toList();
    
    return Game(
      sides: sides,
      dateTime: _parseTimestamp(data['dateTime']) ?? DateTime.now(),
      score: data['score'] as String?,
      status: data['status'] as String? ?? 'upcoming',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sides': sides.map((side) => side.toJson()).toList(),
      'dateTime': Timestamp.fromDate(dateTime),
      'score': score,
      'status': status,
    };
  }

  bool get isUpcoming => status == 'upcoming';
  bool get isLive => status == 'live';
  bool get isCompleted => status == 'completed';

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
