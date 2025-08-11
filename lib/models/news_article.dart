import 'package:cloud_firestore/cloud_firestore.dart';

class NewsArticle {
  final String title;
  final String content;
  final String imageUrl;
  final DateTime publishedAt;
  final String author;
  final String category;
  // Firestore document ID of the team this article belongs to
  final String teamId;

  NewsArticle({
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.publishedAt,
    required this.author,
    required this.category,
    required this.teamId,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String,
      publishedAt: _parseTimestamp(json['publishedAt']) ?? DateTime.now(),
      author: json['author'] as String,
      category: json['category'] as String,
      teamId: json['teamId'] as String,
    );
  }

  factory NewsArticle.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return NewsArticle(
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      publishedAt: _parseTimestamp(data['publishedAt']) ?? DateTime.now(),
      author: data['author'] as String? ?? '',
      category: data['category'] as String? ?? '',
      teamId: data['teamId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'publishedAt': Timestamp.fromDate(publishedAt),
      'author': author,
      'category': category,
      'teamId': teamId,
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
