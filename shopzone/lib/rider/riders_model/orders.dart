

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
  double? sellerLat;
  double? sellerLng;
  String? orderStatus;
  String? thumbnailUrl;
  String? orderId;
  String? orderBy;
  String? orderTime;
  int? itemQuantity;
  String? name;
  String? phoneNumber;
  String? completeAddress;
  String? riderUID;
  String? riderName;
  double? lat;
  double? lng;
  String? address;

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
    this.sellerLat,
    this.sellerLng,
    this.orderStatus,
    this.thumbnailUrl,
    this.orderId,
    this.orderBy,
    this.orderTime,
    this.itemQuantity,
    this.name,
    this.phoneNumber,
    this.completeAddress,
    this.riderUID,
    this.riderName,
    this.lat,
    this.lng,
    this.address,
  });

  Orders.fromJson(Map<String, dynamic> json) {
    brandID = json["brandID"];
    itemID = json["itemID"];
    itemInfo = json["itemInfo"];
    itemTitle = json["itemTitle"];
    longDescription = json["longDescription"];
    if (json["price"] is int) {
      price = json["price"].toString();
    } else {
      price = json["price"];
    }
    if (json["totalAmount"] is int) {
      totalAmount = json["totalAmount"].toString();
    } else {
      totalAmount = json["totalAmount"];
    }
    if (json["publishedDate"] is DateTime) {
      publishedDate = json["publishedDate"] as DateTime;
    }
    sellerName = json["sellerName"];
    sellerUID = json["sellerUID"];
    sellerLat = json['sellerLat'] != null
        ? double.tryParse(json['sellerLat'].toString())
        : null;
    sellerLng = json['sellerLng'] != null
        ? double.tryParse(json['sellerLng'].toString())
        : null;
    orderStatus = json["orderStatus"];
    thumbnailUrl = json["thumbnailUrl"];
    orderId = json["orderId"];
    orderBy = json["orderBy"];

    orderTime = json["orderTime"];

    if (json["itemQuantity"] is int) {
      itemQuantity = json["itemQuantity"] as int?;
    } else if (json["itemQuantity"] is String) {
      int? parsedCounter = int.tryParse(json["itemQuantity"]);
      itemQuantity = parsedCounter;
    }
    name = json["name"];
    phoneNumber = json["phoneNumber"];
    completeAddress = json["completeAddress"];
    riderUID = json["riderUID"];
    riderName = json["riderName"];
    lat = json['lat'] != null ? double.tryParse(json['lat'].toString()) : null;
    lng = json['lng'] != null ? double.tryParse(json['lng'].toString()) : null;
    address = json["address"];
  }
}
