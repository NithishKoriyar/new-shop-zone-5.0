class Items {
  String? brandID;
  String? itemID;
  String? variantID;
  String? itemInfo;
  String? itemTitle;
  String? longDescription;
  String? price;
  String? sellingPrice; // Added sellingPrice
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
  List<String>? SizeName; // Changed to list
  List<String>? ColourName; // Changed to list

  Items({
    this.brandID,
    this.itemID,
    this.variantID,
    this.itemInfo,
    this.itemTitle,
    this.longDescription,
    this.price,
    this.sellingPrice, // Added sellingPrice to constructor
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
    this.SizeName, // Changed to list
    this.ColourName, // Changed to list
  });

  Items.fromJson(Map<String, dynamic> json)
      : brandID = json["brandID"],
        itemID = json["itemID"],
        variantID = json["variantID"],
        itemInfo = json["itemInfo"],
        itemTitle = json["itemTitle"],
        longDescription = json["longDescription"],
        price = json["price"],
        sellingPrice = json["sellingPrice"], // Parse sellingPrice from JSON
        publishedDate = json["publishedDate"] != null
            ? DateTime.parse(json["publishedDate"])
            : null,
        sellerName = json["sellerName"],
        sellerUID = json["sellerUID"],
        status = json["status"],
        thumbnailUrl = json["thumbnailUrl"],
        isWishListed = json["isWishListed"], // Ensure correct key case
        secondImageUrl = json["secondImageUrl"],
        thirdImageUrl = json["thirdImageUrl"],
        fourthImageUrl = json["fourthImageUrl"],
        fifthImageUrl = json["fifthImageUrl"],
        SizeId = json["SizeId"],
        ColourId = json["ColourId"],
        SizeName = (json["SizeName"] as String?)
            ?.split(',')
            .map((e) => e.trim())
            .toList(), // Parse to list
        ColourName = (json["ColourName"] as String?)
            ?.split(',')
            .map((e) => e.trim())
            .toList(); // Parse to list

  Map<String, dynamic> toJson() {
    return {
      "brandID": brandID,
      "itemID": itemID,
      "variantID": variantID,
      "itemInfo": itemInfo,
      "itemTitle": itemTitle,
      "longDescription": longDescription,
      "price": price,
      "sellingPrice": sellingPrice, // Convert sellingPrice to JSON
      "publishedDate": publishedDate?.toIso8601String(),
      "sellerName": sellerName,
      "sellerUID": sellerUID,
      "status": status,
      "thumbnailUrl": thumbnailUrl,
      "secondImageUrl": secondImageUrl,
      "thirdImageUrl": thirdImageUrl,
      "fourthImageUrl": fourthImageUrl,
      "fifthImageUrl": fifthImageUrl,
      "isWishListed": isWishListed, // Ensure correct key case
      "SizeId": SizeId,
      "ColourId": ColourId,
      "SizeName": SizeName?.join(','), // Convert list to comma-separated string
      "ColourName": ColourName?.join(','), // Convert list to comma-separated string
    };
  }
}
