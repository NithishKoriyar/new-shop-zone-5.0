import 'package:cloud_firestore/cloud_firestore.dart';

class Orders {
  String? brandID;
  String? itemID;
  String? itemInfo;
  String? itemTitle;
  String? longDescription;
  String? price;
  String? totalAmount;
  Timestamp? publishedDate;
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
    if (json["publishedDate"] is Timestamp) {
      publishedDate = json["publishedDate"] as Timestamp;
    }
    sellerName = json["sellerName"];
    sellerUID = json["sellerUID"];
    orderStatus = json["orderStatus"];
    thumbnailUrl = json["thumbnailUrl"];
    orderId = json["orderId"];

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
  }
}
