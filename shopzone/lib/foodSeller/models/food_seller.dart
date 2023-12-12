class Seller {
  int seller_id;
  String seller_name;
  String seller_email;
  String seller_password;
  String seller_profile;
  String seller_phone;
  String seller_address;

  Seller(
    this.seller_id,
    this.seller_name,
    this.seller_email,
    this.seller_password,
    this.seller_profile,
    this.seller_phone,
    this.seller_address,
  );

  factory Seller.fromJson(Map<String, dynamic> json) {
    int parsedId = json["seller_id"] != null ? int.parse(json["seller_id"]) : 0;
    return Seller(
      parsedId,
      json["seller_name"] ?? '',
      json["seller_email"] ?? '',
      json["seller_password"] ?? '',
      json["seller_profile"] ?? '',
      json["seller_phone"] ?? '',
      json["seller_address"] ?? '',
    );
  }



  Map<String, dynamic> toJson() => {
        'seller_id': seller_id.toString(),
        'seller_name': seller_name,
        'seller_email': seller_email,
        'seller_password': seller_password,
        'seller_profile': seller_profile,
        'seller_phone' : seller_phone,
        'seller_address':seller_address,
      };
}
