import 'package:cloud_firestore/cloud_firestore.dart';

class FanPhoto {
  final String username;
  final String imageUrl;
  final String caption;
  final DateTime uploadedAt;
  final int likes;
  final String teamId; // Firestore document ID of the team this photo belongs to
  final String userId; // Firebase Auth UID of the user who uploaded the photo
  final List<String> likedBy; // Array of user IDs who liked this photo

  FanPhoto({
    required this.username,
    required this.imageUrl,
    required this.caption,
    required this.uploadedAt,
    required this.likes,
    required this.teamId,
    required this.userId,
    required this.likedBy,
  });

  factory FanPhoto.fromJson(Map<String, dynamic> json) {
    return FanPhoto(
      username: json['username'],
      imageUrl: json['imageUrl'],
      caption: json['caption'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      likes: json['likes'],
      teamId: json['teamId'],
      userId: json['userId'],
      likedBy: List<String>.from(json['likedBy'] ?? []),
    );
  }

  factory FanPhoto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return FanPhoto(
      username: data['username'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      caption: data['caption'] as String? ?? '',
      uploadedAt: _parseTimestamp(data['uploadedAt']) ?? DateTime.now(),
      likes: data['likes'] as int? ?? 0,
      teamId: data['teamId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'imageUrl': imageUrl,
      'caption': caption,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'likes': likes,
      'teamId': teamId,
      'userId': userId,
      'likedBy': likedBy,
    };
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
