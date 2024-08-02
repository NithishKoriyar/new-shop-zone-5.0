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
  String? product_quantity;
  String? SizeId;
  String? ColourId;
  String? ColourName;
  String? SizeName;

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
    this.product_quantity,
    this.SizeId,
    this.ColourId,
    this.ColourName,
    this.SizeName,
  });

  Items.fromJson(Map<String, dynamic> json) {
    brandID = json["brandID"];
    itemID = json["itemID"];
    itemInfo = json["itemInfo"];
    itemTitle = json["itemTitle"];
    longDescription = json["longDescription"];
    price = json["price"];
    if (json["publishedDate"] != null && json["publishedDate"] is String) {
      publishedDate = DateTime.parse(json["publishedDate"]);
    }
    sellerName = json["sellerName"];
    sellerUID = json["sellerUID"];
    status = json["status"];
    thumbnailUrl = json["thumbnailUrl"];
    product_quantity = json["product_quantity"];
    SizeId = json["SizeId"];
    ColourId = json["ColourId"];
    ColourName = json["ColourName"];
    SizeName = json["SizeName"];
  }

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
      "product_quantity": product_quantity,
      "SizeId": SizeId,
      "ColourId": ColourId,
      "ColourName": ColourName,
      "SizeName": SizeName,
    };
  }
}
