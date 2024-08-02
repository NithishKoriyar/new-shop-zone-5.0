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
  String? SizeId;
  String? ColourId;
  String? SizeName;  // corrected naming convention
  String? ColourName;  // corrected naming convention

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
    this.SizeId,
    this.ColourId,
    this.SizeName,  // corrected naming convention
    this.ColourName,  // corrected naming convention
  });

  Items.fromJson(Map<String, dynamic> json)
      : brandID = json["brandID"],
        itemID = json["itemID"],
        itemInfo = json["itemInfo"],
        itemTitle = json["itemTitle"],
        longDescription = json["longDescription"],
        price = json["price"],
        publishedDate = json["publishedDate"] != null
            ? DateTime.parse(json["publishedDate"])
            : null,
        sellerName = json["sellerName"],
        sellerUID = json["sellerUID"],
        status = json["status"],
        thumbnailUrl = json["thumbnailUrl"],
        isWishListed = json["isWishListed"],  // ensure correct key case
        secondImageUrl = json["secondImageUrl"],
        thirdImageUrl = json["thirdImageUrl"],
        fourthImageUrl = json["fourthImageUrl"],
        fifthImageUrl = json["fifthImageUrl"],
        SizeId = json["SizeId"],
        ColourId = json["ColourId"],
        SizeName = json["SizeName"],  // corrected naming convention
        ColourName = json["ColourName"];  // corrected naming convention

  Map<String, dynamic> toJson() {
    return {
      "brandID": brandID,
      "itemID": itemID,
      "itemInfo": itemInfo,
      "itemTitle": itemTitle,
      "longDescription": longDescription,
      "price": price,
      "publishedDate": publishedDate?.toIso8601String(),
      "sellerName": sellerName,
      "sellerUID": sellerUID,
      "status": status,
      "thumbnailUrl": thumbnailUrl,
      "secondImageUrl": secondImageUrl,
      "thirdImageUrl": thirdImageUrl,
      "fourthImageUrl": fourthImageUrl,
      "fifthImageUrl": fifthImageUrl,
      "isWishListed": isWishListed,  // ensure correct key case
      "SizeId": SizeId,
      "ColourId": ColourId,
      "SizeName": SizeName,  // corrected naming convention
      "ColourName": ColourName,  // corrected naming convention
    };
  }
}
