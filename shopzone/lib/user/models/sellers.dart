class Sellers {
  final int sellerId;
  final String sellerName;
  final String sellerEmail;
  final String sellerPassword; // Storing passwords in plain text or even hashed in front-end models is a big security risk! You shouldn't really be doing this.
  final String sellerProfile;
  final String sellerPhone;
  final String sellerAddress;
  final double rating;

  Sellers({
    required this.sellerId,
    required this.sellerName,
    required this.sellerEmail,
    required this.sellerPassword,
    required this.sellerProfile,
    required this.sellerPhone,
    required this.sellerAddress,
    required this.rating,
  });

  // Factory constructor to create an instance of Sellers from a map
factory Sellers.fromJson(Map<String, dynamic> json) {
  int parsedId = json["seller_id"] != null ? int.parse(json["seller_id"]) : 0;
  double parsedRating = json['rating'] != null ? double.tryParse(json['rating'].toString()) ?? 0.0 : 0.0;

  return Sellers(
    sellerId: parsedId,
    sellerName: json['seller_name'] is String ? json['seller_name'] : '',
    sellerEmail: json['seller_email'] is String ? json['seller_email'] : '',
    sellerPassword: json['seller_password'] is String ? json['seller_password'] : '',
    sellerProfile: json['seller_profile'] is String ? json['seller_profile'] : '',
    sellerPhone: json['seller_phone'] is String ? json['seller_phone'] : '',
    sellerAddress: json['seller_address'] is String ? json['seller_address'] : '',
    rating: parsedRating,
  );
}



  // Convert Sellers instance to a map
  Map<String, dynamic> toJson() {
    return {
      'seller_id': sellerId,
      'seller_name': sellerName,
      'seller_email': sellerEmail,
      'seller_password': sellerPassword,
      'seller_profile': sellerProfile,
      'seller_phone': sellerPhone,
      'seller_address': sellerAddress,
      'rating': rating,
    };
  }
}
