class Carts {
  String? cartId;
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
  int? itemCounter;
  int? totalPrice;
  String? sellingPrice; // New property for selling price

  // New properties
  String? isWishListed;
  String? secondImageUrl;
  String? thirdImageUrl;
  String? fourthImageUrl;
  String? fifthImageUrl;
  String? sizeId;
  String? colourId;
  String? sizeName;
  String? colourName;

  Carts({
    this.cartId,
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
    this.itemCounter,
    this.totalPrice,
    this.sellingPrice, // Added to constructor
    this.isWishListed,
    this.secondImageUrl,
    this.thirdImageUrl,
    this.fourthImageUrl,
    this.fifthImageUrl,
    this.sizeId,
    this.colourId,
    this.sizeName,
    this.colourName,
  });

  Carts.fromJson(Map<String, dynamic> json) {
    cartId = json["cartId"];
    brandID = json["brandID"];
    itemID = json["itemID"];
    itemInfo = json["itemInfo"];
    itemTitle = json["itemTitle"];
    longDescription = json["longDescription"];
    price = json["price"];
    sellingPrice = json["sellingPrice"]; // Added to fromJson method

    if (json["publishedDate"] is DateTime) {
      publishedDate = json["publishedDate"] as DateTime;
    }
    sellerName = json["sellerName"];
    sellerUID = json["sellerUID"];
    status = json["status"];
    thumbnailUrl = json["thumbnailUrl"];

    if (json["itemCounter"] is int) {
      itemCounter = json["itemCounter"] as int?;
    } else if (json["itemCounter"] is String) {
      int? parsedCounter = int.tryParse(json["itemCounter"]);
      itemCounter = parsedCounter;
    }

    if (json["totalPrice"] is int) {
      totalPrice = json["totalPrice"] as int?;
    } else if (json["totalPrice"] is String) {
      int? parsedCounter = int.tryParse(json["totalPrice"]);
      totalPrice = parsedCounter;
    }

    // Parse new fields
    isWishListed = json["isWishListed"];
    secondImageUrl = json["secondImageUrl"];
    thirdImageUrl = json["thirdImageUrl"];
    fourthImageUrl = json["fourthImageUrl"];
    fifthImageUrl = json["fifthImageUrl"];
    sizeId = json["sizeId"];
    colourId = json["colourId"];

    sizeName = json["SizeName"];
    colourName = json["ColourName"];
  }
}
