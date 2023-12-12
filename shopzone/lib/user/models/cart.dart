import 'package:cloud_firestore/cloud_firestore.dart';

class Carts {
  String? cartId;
  String? brandID;
  String? itemID;
  String? itemInfo;
  String? itemTitle;
  String? longDescription;
  String? price;
  Timestamp? publishedDate;
  String? sellerName;
  String? sellerUID;
  String? status;
  String? thumbnailUrl;
  int? itemCounter;
  int? totalPrice;

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
  });

  Carts.fromJson(Map<String, dynamic> json) {
    cartId = json["cartId"];
    brandID = json["brandID"];
    itemID = json["itemID"];
    itemInfo = json["itemInfo"];
    itemTitle = json["itemTitle"];
    longDescription = json["longDescription"];
    price = json["price"];

    if (json["publishedDate"] is Timestamp) {
      publishedDate = json["publishedDate"] as Timestamp;
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
  }
}
