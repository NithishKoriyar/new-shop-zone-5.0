
class Brands {
  String? brandID;
  String? brandInfo;
  String? brandTitle;
  DateTime? publishedDate; // <-- Change this to DateTime
  String? sellerUID;
  String? status;
  String? thumbnailUrl;

  Brands({
    this.brandID,
    this.brandInfo,
    this.brandTitle,
    this.publishedDate,
    this.sellerUID,
    this.status,
    this.thumbnailUrl,
  });

  Brands.fromJson(Map<String, dynamic> json) {
    brandID = json["brandID"];
    brandInfo = json["brandInfo"];
    brandTitle = json["brandTitle"];
    if (json["publishedDate"] != null) {  // Handle the case where "publishedDate" could be null
      publishedDate = DateTime.parse(json["publishedDate"]);
    }
    sellerUID = json["sellerUID"];
    status = json["status"];
    thumbnailUrl = json["thumbnailUrl"];
  }
}
