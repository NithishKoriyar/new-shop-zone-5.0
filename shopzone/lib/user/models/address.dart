class Address
{
  String? uid;
  String? name;
  String? phoneNumber;
  String? streetNumber;
  String? flatHouseNumber;
  String? city;
  String? stateCountry;
  String? completeAddress;


  Address({
    this.uid,
    this.name,
    this.phoneNumber,
    this.streetNumber,
    this.flatHouseNumber,
    this.city,
    this.stateCountry,
    this.completeAddress,
  });

  Address.fromJson(Map<String, dynamic> json)
  {
    uid = json["uid"];
    name = json['name'];
    phoneNumber = json['phoneNumber'];
    streetNumber = json['streetNumber'];
    flatHouseNumber = json['flatHouseNumber'];
    city = json['city'];
    stateCountry = json['stateCountry'];
    completeAddress = json['completeAddress'];
  }
}