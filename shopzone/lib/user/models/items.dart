

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
      "IsWishlisted": isWishListed,
    };
  }
}
