class Orders {
  String? brandID;
  String? itemID;
  String? itemInfo;
  String? itemTitle;
  String? longDescription;
  String? price;
  String? totalAmount;
  DateTime? publishedDate;
  String? sellerName;
  String? sellerUID;
  String? orderStatus;
  String? thumbnailUrl;
  String? orderId;
  String? orderTime;
  int? itemQuantity;
  String? name;
  String? phoneNumber;
  String? completeAddress;
  double? lat;
  double? lng;
  String? userID; // Added user ID

  Orders({
    this.brandID,
    this.itemID,
    this.itemInfo,
    this.itemTitle,
    this.longDescription,
    this.price,
    this.totalAmount,
    this.publishedDate,
    this.sellerName,
    this.sellerUID,
    this.orderStatus,
    this.thumbnailUrl,
    this.orderId,
    this.orderTime,
    this.itemQuantity,
    this.name,
    this.phoneNumber,
    this.completeAddress,
    this.lat,
    this.lng,
    this.userID, // Initialize user ID
  });

  Orders.fromJson(Map<String, dynamic> json) {
    brandID = json["brandID"];
    itemID = json["itemID"];
    itemInfo = json["itemInfo"];
    itemTitle = json["itemTitle"];
    longDescription = json["longDescription"];
    price = json["price"] is int ? json["price"].toString() : json["price"];
    totalAmount = json["totalAmount"] is int ? json["totalAmount"].toString() : json["totalAmount"];
    publishedDate = json["publishedDate"] is DateTime ? json["publishedDate"] as DateTime : null;
    sellerName = json["sellerName"];
    sellerUID = json["sellerUID"];
    orderStatus = json["orderStatus"];
    thumbnailUrl = json["thumbnailUrl"];
    orderId = json["orderId"];
    orderTime = json["orderTime"];
    itemQuantity = json["itemQuantity"] is String ? int.tryParse(json["itemQuantity"]) : json["itemQuantity"];
    name = json["name"];
    phoneNumber = json["phoneNumber"];
    completeAddress = json["completeAddress"];
    lat = json["lat"] != null ? double.tryParse(json["lat"]) : null;
    lng = json["lng"] != null ? double.tryParse(json["lng"]) : null;
    userID = json["userID"]; // Parse user ID from JSON if available
  }
}
