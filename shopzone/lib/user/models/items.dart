class Items {
  String? brandID;
  String? itemID;
  String? itemInfo;
  String? itemTitle;
  String? longDescription;
  String? price;
  DateTime? publishedDate;
  String? sellerName;
  String? sellerUID;
  String? status;
  String? thumbnailUrl;
  String? isWishListed;
  String? secondImageUrl;
  String? thirdImageUrl;
  String? fourthImageUrl;
  String? fifthImageUrl;

  Items({
    this.brandID,
    this.itemID,
    this.itemInfo,
    this.itemTitle,
    this.longDescription,
    this.price,
    this.publishedDate,
    this.sellerName,
    this.sellerUID,
    this.status,
    this.thumbnailUrl,
    this.isWishListed,
    this.secondImageUrl,
    this.thirdImageUrl,
    this.fourthImageUrl,
    this.fifthImageUrl,
  });

  Items.fromJson(Map<String, dynamic> json)
      : brandID = json["brandID"],
        itemID = json["itemID"],
        itemInfo = json["itemInfo"],
        itemTitle = json["itemTitle"],
        longDescription = json["longDescription"],
        price = json["price"],
        publishedDate = json["publishedDate"] is DateTime
            ? json["publishedDate"] as DateTime
            : null,
        sellerName = json["sellerName"],
        sellerUID = json["sellerUID"],
        status = json["status"],
        thumbnailUrl = json["thumbnailUrl"],
          secondImageUrl = json["secondImageUrl"],
            thirdImageUrl = json["thirdImageUrl"],
              fourthImageUrl = json["fourthImageUrl"],
                fifthImageUrl = json["fifthImageUrl"],

        isWishListed = json["IsWishlisted"];

  get discount => null;

  Map<String, dynamic> toJson() {
    return {
      "brandID": brandID,
      "itemID": itemID,
      "itemInfo": itemInfo,
      "itemTitle": itemTitle,
      "longDescription": longDescription,
      "price": price,
      "publishedDate": publishedDate,
      "sellerName": sellerName,
      "sellerUID": sellerUID,
      "status": status,
      "thumbnailUrl": thumbnailUrl,
      "secondImageUrl": secondImageUrl,
      "thirdImageUrl": thirdImageUrl,
      "fourthImageUrl": fourthImageUrl,
      "fifthImageUrl": fifthImageUrl,
      "IsWishlisted": isWishListed,
    };
  }
}
