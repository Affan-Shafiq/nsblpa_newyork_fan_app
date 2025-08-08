class NewsArticle {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final DateTime publishedAt;
  final String author;
  final String category;
  final bool isVideo;
  final String? videoUrl;

  NewsArticle({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.publishedAt,
    required this.author,
    required this.category,
    this.isVideo = false,
    this.videoUrl,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      publishedAt: DateTime.parse(json['publishedAt']),
      author: json['author'],
      category: json['category'],
      isVideo: json['isVideo'] ?? false,
      videoUrl: json['videoUrl'],
    );
  }
}
