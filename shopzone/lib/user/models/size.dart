class Size {
  String? SizeId;
  String? SizeName;

  Size({this.SizeId, this.SizeName});

  // Factory constructor to create a Size object from JSON
  factory Size.fromJson(Map<String, dynamic> json) {
    return Size(
      SizeId: json['SizeId'],
      SizeName: json['SizeName'],
    );
  }

  // Method to convert a Size object to JSON
  Map<String, dynamic> toJson() {
    return {
      'SizeId': SizeId,
      'SizeName': SizeName,
    };
  }
}
