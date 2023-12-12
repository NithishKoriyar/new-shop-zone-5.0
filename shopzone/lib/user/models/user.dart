class User {
  int user_id;
  String user_name;
  String user_email;
  String user_password;
  String user_profile;

  User(
    this.user_id,
    this.user_name,
    this.user_email,
    this.user_password,
    this.user_profile,
  );

  factory User.fromJson(Map<String, dynamic> json) {
    int parsedId = json["user_id"] != null ? int.parse(json["user_id"]) : 0;
    return User(
      parsedId,
      json["user_name"] ?? '',
      json["user_email"] ?? '',
      json["user_password"] ?? '',
      json["user_profile"] ?? '',
    );
  }



  Map<String, dynamic> toJson() => {
        'user_id': user_id.toString(),
        'user_name': user_name,
        'user_email': user_email,
        'user_password': user_password,
        'user_profile': user_profile,
      };
}
