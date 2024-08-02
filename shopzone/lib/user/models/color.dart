class Colour {
  String? ColourId;
  String? ColourName;

  Colour({this.ColourId, this.ColourName});

  // Factory constructor to create a Colour object from JSON
  factory Colour.fromJson(Map<String, dynamic> json) {
    return Colour(
      ColourId: json['ColourId'],
      ColourName: json['ColourName'],
    );
  }

  // Method to convert a Colour object to JSON
  Map<String, dynamic> toJson() {
    return {
      'ColourId': ColourId,
      'ColourName': ColourName,
    };
  }
}
