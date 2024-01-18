//so in the code the data is sent from registerPage in userInfo it will
//remember user as currentUser
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../riders_model/riders_user.dart';


class RememberRiderPrefs
{
  //save-remember User-info
  static Future<void> storeRiderInfo(Rider riderInfo) async
  {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String userJsonData = jsonEncode(riderInfo.toJson());
    await preferences.setString("currentRider", userJsonData);
  }

  //get-read User-info
  static Future<Rider?> readRiderInfo() async
  {
    Rider? currentRiderInfo;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? riderInfo = preferences.getString("currentRider");
    if(riderInfo != null)
    {
      Map<String, dynamic> userDataMap = jsonDecode(riderInfo);
      currentRiderInfo = Rider.fromJson(userDataMap);
    }
    return currentRiderInfo;
  }
  //
  static Future<void> removeUserInfo() async
  {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove("currentRider");
  }
}