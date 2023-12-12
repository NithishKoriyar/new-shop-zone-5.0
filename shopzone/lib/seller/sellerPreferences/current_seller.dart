
import 'package:get/get.dart';
import 'package:shopzone/seller/models/seller.dart';
import 'package:shopzone/seller/sellerPreferences/seller_preferences.dart';

class CurrentSeller extends GetxController
{
  Rx<Seller> _currentSeller = Seller(0,'','','','','','').obs;

  Seller get seller => _currentSeller.value;


  getSellerInfo() async
  {
    Seller? getSellerInfoFromLocalStorage = await RememberSellerPrefs.readSellerInfo();
    _currentSeller.value = getSellerInfoFromLocalStorage!;
  }
}


