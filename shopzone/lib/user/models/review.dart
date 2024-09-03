class Review {
  final int id;
  final String userID;
  final String sellerUID;
  final int itemId;
  final int rating;
  final String reviewText;
  final String? videoUrl;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userID,
    required this.sellerUID,
    required this.itemId,
    required this.rating,
    required this.reviewText,
    this.videoUrl,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userID: json['user_id'],
      sellerUID: json['sellerUID'],
      itemId: json['item_id'],
      rating: json['rating'],
      reviewText: json['review_text'],
      videoUrl: json['video_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
