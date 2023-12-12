import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopzone/seller/models/seller.dart';

class RememberSellerPrefs
{
  //save-remember User-info
  static Future<void> storeSellerInfo(Seller sellerInfo) async
  {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String sellerJsonData = jsonEncode(sellerInfo.toJson());
    await preferences.setString("currentSeller", sellerJsonData);
  }

  //get-read User-info
  static Future<Seller?> readSellerInfo() async
  {
    Seller? currentSellerInfo;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? sellerInfo = preferences.getString("currentSeller");
    if(sellerInfo != null)
    {
      Map<String, dynamic> sellerDataMap = jsonDecode(sellerInfo);
      currentSellerInfo = Seller.fromJson(sellerDataMap);
    }
    return currentSellerInfo;
  }

  static Future<void> removeSellerInfo() async
  {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove("currentSeller");
  }
}