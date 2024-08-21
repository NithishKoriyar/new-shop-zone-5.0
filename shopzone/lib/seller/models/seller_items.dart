class Items {
  String? brandID;
  String? itemID;
  String? variantID;
  String? itemInfo;
  String? itemTitle;
  String? longDescription;
  String? price;
  String? sellingPrice; // Added sellingPrice field
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
  String? category_id;
  String? sub_category_id;

  Items({
    this.brandID,
    this.itemID,
    this.variantID,
    this.itemInfo,
    this.itemTitle,
    this.longDescription,
    this.price,
    this.sellingPrice, // Added sellingPrice field
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
    this.category_id,
    this.sub_category_id,
  });

  Items.fromJson(Map<String, dynamic> json) {
    brandID = json["brandID"];
    itemID = json["itemID"];
    variantID = json["variantID"];
    itemInfo = json["itemInfo"];
    itemTitle = json["itemTitle"];
    longDescription = json["longDescription"];
    price = json["price"];
    sellingPrice = json["sellingPrice"]; // Added sellingPrice field
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
    category_id = json["category_id"];
    sub_category_id = json["sub_category_id"];
  }

  Map<String, dynamic> toJson() {
    return {
      "brandID": brandID,
      "itemID": itemID,
      "variantID": variantID,
      "itemInfo": itemInfo,
      "itemTitle": itemTitle,
      "longDescription": longDescription,
      "price": price,
      "sellingPrice": sellingPrice, // Added sellingPrice field
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
      "category_id": category_id,
      "sub_category_id": sub_category_id,
    };
  }
}
