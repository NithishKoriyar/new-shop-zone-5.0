//Note: The DataBase Structure should be Same as this structure  otherwise it will conflict
//in login process
//so this is user class it receives the data and changes to json

class Rider {
  int riders_id;
  String riders_name;
  String riders_email;
  String riders_password;
  String riders_phone;
  String riders_location;
  String riders_image;

  Rider(
      this.riders_id,
      this.riders_name,
      this.riders_email,
      this.riders_password,
      this.riders_phone,
      this.riders_location,
      this.riders_image,
      );

  factory Rider.fromJson(Map<String, dynamic> json) => Rider(
    int.parse(json["riders_id"]),
    json["riders_name"],
    json["riders_email"],
    json["riders_password"],
    json["riders_phone"],
    json["riders_location"],
    json["riders_image"],
  );

  Map<String, dynamic> toJson() => {
    'riders_id': riders_id.toString(),
    'riders_name': riders_name,
    'riders_email': riders_email,
    'riders_password': riders_password,
    'riders_phone': riders_phone,
    'riders_location': riders_location,
    'riders_image': riders_image,
  };
}
