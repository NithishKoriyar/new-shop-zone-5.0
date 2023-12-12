
import 'package:get/get.dart';
import 'package:shopzone/foodSeller/foodSellerPreferences/food_seller_preferences.dart';
import 'package:shopzone/foodSeller/models/food_seller.dart';

class CurrentFoodSeller extends GetxController
{
  Rx<Seller> _currentFoodSeller = Seller(0,'','','','','','').obs;

  Seller get seller => _currentFoodSeller.value;


  getSellerInfo() async
  {
    Seller? getSellerInfoFromLocalStorage = await RememberFoodSellerPrefs.readSellerInfo();
    _currentFoodSeller.value = getSellerInfoFromLocalStorage!;
  }
}


