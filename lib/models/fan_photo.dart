class FanPhoto {
  final String id;
  final String username;
  final String imageUrl;
  final String caption;
  final DateTime uploadedAt;
  final int likes;
  final bool isFeatured;
  final String? socialMediaUrl;

  FanPhoto({
    required this.id,
    required this.username,
    required this.imageUrl,
    required this.caption,
    required this.uploadedAt,
    required this.likes,
    this.isFeatured = false,
    this.socialMediaUrl,
  });

  factory FanPhoto.fromJson(Map<String, dynamic> json) {
    return FanPhoto(
      id: json['id'],
      username: json['username'],
      imageUrl: json['imageUrl'],
      caption: json['caption'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      likes: json['likes'],
      isFeatured: json['isFeatured'] ?? false,
      socialMediaUrl: json['socialMediaUrl'],
    );
  }
}
